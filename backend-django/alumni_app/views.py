from django.shortcuts import render, get_object_or_404
from django.http import HttpResponse

# Create your views here.
def home_view(request):
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Alumni Management System</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 800px; margin: 0 auto; }
            h1 { color: #2c3e50; }
            .api-link { display: block; margin: 10px 0; padding: 10px; background: #f8f9fa; border-left: 4px solid #007bff; }
            .api-link a { text-decoration: none; color: #007bff; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🎓 Alumni Management System API</h1>
            <p>Welcome to the Alumni Management System backend!</p>
            
            <h2>Available API Endpoints:</h2>
            <div class="api-link"><a href="/api/alumni/">📋 Alumni List</a> - View all alumni</div>
            <div class="api-link"><a href="/api/events/">📅 Events List</a> - View all events</div>
            <div class="api-link"><a href="/admin/">⚙️ Admin Panel</a> - Django admin interface</div>
            
            <h2>Authentication Endpoints:</h2>
            <div class="api-link">POST /api/register/ - Register new user</div>
            <div class="api-link">POST /api/login/ - Login user</div>
            <div class="api-link">POST /api/logout/ - Logout user</div>
            
            <p><strong>Note:</strong> Most endpoints require authentication. Use the login endpoint to get a token first.</p>
        </div>
    </body>
    </html>
    """
    return HttpResponse(html_content)

from rest_framework import viewsets, generics, permissions
from django.utils.timezone import now
from django.db.models import Count
from .models import Alumni, Event, AlumniEvent, PreviousContact
from .serializers import AlumniSerializer, EventSerializer, AlumniEventSerializer, RegisterSerializer, PreviousContactSerializer, LogoutSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
 
from django.contrib.auth.models import User 
from django.contrib.auth import authenticate
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework.response import Response
from rest_framework import status

from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_str, force_bytes
from django.core.mail import send_mail
from django.urls import reverse

from django.http import JsonResponse
import logging

from django_filters import rest_framework as filters
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
logger = logging.getLogger(__name__)

# CRUD for Alumni
class AlumniFilter(filters.FilterSet):
    name = filters.CharFilter(lookup_expr='icontains')
    email = filters.CharFilter(lookup_expr='icontains')
    country = filters.CharFilter(lookup_expr='icontains')
    prior_course = filters.CharFilter(lookup_expr='icontains')
    year_of_graduation = filters.NumberFilter()
    company = filters.CharFilter(lookup_expr='exact')
    area_of_expertise = filters.CharFilter(method='filter_expertise')

    def filter_expertise(self, queryset, name, value):
        return queryset.filter(area_of_expertise__contains=[value])

    class Meta:
        model = Alumni
        fields = ['name', 'email', 'country', 'prior_course', 
                 'year_of_graduation', 'company',
                 'area_of_expertise']
class AlumniListCreateView(generics.ListCreateAPIView):
    queryset = Alumni.objects.all()
    serializer_class = AlumniSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_class = AlumniFilter
    search_fields = ['name', 'email', 'country', 'prior_course', 'company']
    ordering_fields = ['name', 'year_of_graduation', 'company']
    ordering = ['name']  # default ordering

    def create(self, request, *args, **kwargs):
        try:
            response = super().create(request, *args, **kwargs)
            return Response({
                'message': 'Alumni created successfully',
                'data': response.data
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            logger.error(f"Error creating alumni: {e}")
            return Response({
                'error': 'Failed to create alumni'
            }, status=status.HTTP_400_BAD_REQUEST)

class AlumniDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Alumni.objects.all()
    serializer_class = AlumniSerializer
    permission_classes = [IsAuthenticated]

    def update(self, request, *args, **kwargs):
        try:
            response = super().update(request, *args, **kwargs)
            return Response({
                'message': 'Alumni updated successfully',
                'data': response.data
            })
        except Exception as e:
            logger.error(f"Error updating alumni: {e}")
            return Response({
                'error': 'Failed to update alumni'
            }, status=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, *args, **kwargs):
        try:
            super().destroy(request, *args, **kwargs)
            return Response({
                'message': 'Alumni deleted successfully'
            }, status=status.HTTP_204_NO_CONTENT)
        except Exception as e:
            logger.error(f"Error deleting alumni: {e}")
            return Response({
                'error': 'Failed to delete alumni'
            }, status=status.HTTP_400_BAD_REQUEST)

# CRUD for Events
class EventListCreateView(generics.ListCreateAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer

class EventDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer

class RecommendedAlumniViewSet(viewsets.ModelViewSet):
    serializer_class = AlumniSerializer

    def get_queryset(self):
        event_id = self.request.query_params.get('event_id')
        if not event_id:
            return Alumni.objects.none()

        # Confirm the event exists (404s cleanly otherwise)
        get_object_or_404(Event, id=event_id)

        # Event no longer has an area_of_interest field to match against
        # (removed in migration 0009), so recommend alumni prioritized by
        # how many events they've previously attended.
        return Alumni.objects.annotate(
            events_attended=Count('alumnievent')
        ).order_by('-events_attended')

# Register New Users
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

# Login (Token-Based Authentication)
class CustomTokenObtainPairView(TokenObtainPairView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request, *args, **kwargs):
        try:
            username = request.data.get('username')
            password = request.data.get('password')
            
            # Debug logging
            logger.info(f"Login attempt for user: {username}")
            
            if not username or not password:
                return Response({
                    'error': 'Username and password are required'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Try to find user by username or email
            try:
                if '@' in username:
                    user = User.objects.get(email=username)
                    username = user.username  # Use the username for authentication
                else:
                    user = User.objects.get(username=username)
            except User.DoesNotExist:
                logger.warning(f"Login failed: User {username} does not exist")
                return Response({
                    'error': 'User does not exist'
                }, status=status.HTTP_404_NOT_FOUND)
            
            if not user.is_active:
                logger.warning(f"Login failed: User {username} is not active")
                return Response({
                    'error': 'User account is not active'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Try to authenticate
            auth_user = authenticate(username=username, password=password)
            if not auth_user:
                logger.warning(f"Login failed: Invalid credentials for {username}")
                return Response({
                    'error': 'Invalid credentials'
                }, status=status.HTTP_401_UNAUTHORIZED)
            
            # Get the token
            request.data['username'] = username  # Ensure correct username is used
            response = super().post(request, *args, **kwargs)
            
            logger.info(f"Login successful for user: {username}")
            return Response({
                'status': 'success',
                'token': response.data['access'],
                'refresh': response.data['refresh']
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            logger.error(f"Login error: {str(e)}")
            return Response({
                'error': f'Login failed: {str(e)}'
            }, status=status.HTTP_401_UNAUTHORIZED)

# Password Reset (Email-Based)
class ForgotPasswordView(generics.GenericAPIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get('email')
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        # Generate Password Reset Token
        token = default_token_generator.make_token(user)
        uid = urlsafe_base64_encode(force_bytes(user.pk))
        reset_url = f"http://localhost:8000/reset-password/{uid}/{token}/"

        # Send Email
        try:
            send_mail(
                "Password Reset",
                f"Click the link to reset your password: {reset_url}",
                "noreply@alumniapp.com",
                [email],
                fail_silently=False,
            )
        except Exception as e:
            logger.error(f"Error sending email: {e}")
            return Response({'error': 'Error sending email'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({'message': 'Password reset link sent'}, status=status.HTTP_200_OK)
    
# Logout (Blacklist Refresh Token)
class LogoutView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = LogoutSerializer

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Successfully logged out"}, status=status.HTTP_204_NO_CONTENT)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# CRUD for PreviousContact
class PreviousContactViewSet(viewsets.ModelViewSet):
    queryset = PreviousContact.objects.all()
    serializer_class = PreviousContactSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        # Automatically set the contacted_by field to the current user
        serializer.save(contacted_by=self.request.user)

    def get_queryset(self):
        # Filter contacts based on search parameters
        queryset = PreviousContact.objects.all()
        alumni_id = self.request.query_params.get('alumni', None)

        if alumni_id:
            queryset = queryset.filter(alumni_id=alumni_id)

        return queryset.order_by('-date')  # Most recent contacts first

# CRUD for AlumniEvent (attendance)
class AlumniEventViewSet(viewsets.ModelViewSet):
    queryset = AlumniEvent.objects.all()
    serializer_class = AlumniEventSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = AlumniEvent.objects.all()
        alumni_id = self.request.query_params.get('alumni', None)

        if alumni_id:
            queryset = queryset.filter(alumni_id=alumni_id)

        return queryset.order_by('-attended_on')  # Most recent attendance first