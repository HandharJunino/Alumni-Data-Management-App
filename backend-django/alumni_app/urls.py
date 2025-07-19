from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    AlumniListCreateView, 
    AlumniDetailView, 
    EventListCreateView, 
    EventDetailView, 
    RegisterView, 
    CustomTokenObtainPairView, 
    ForgotPasswordView,
    PreviousContactViewSet,
    RecommendedAlumniViewSet,
    LogoutView,
    home_view
)
from rest_framework_simplejwt.views import TokenRefreshView

# Create a router for ViewSets
router = DefaultRouter()
router.register(r'previous-contacts', PreviousContactViewSet, basename='previous-contact')
router.register(r'recommended-alumni', RecommendedAlumniViewSet, basename='recommended-alumni')

urlpatterns = [
    # Home page
    path('', home_view, name='home'),
    
    # Include router URLs
    path('api/', include(router.urls)),
    
    # Regular views
    path('api/alumni/', AlumniListCreateView.as_view(), name='alumni-list'),
    path('api/alumni/<int:pk>/', AlumniDetailView.as_view(), name='alumni-detail'),
    path('api/events/', EventListCreateView.as_view(), name='event-list-create'),
    path('api/events/<int:pk>/', EventDetailView.as_view(), name='event-detail'),
    
    # Authentication endpoints
    path('api/register/', RegisterView.as_view(), name='register'),
    path('api/login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/login/', CustomTokenObtainPairView.as_view(), name='login'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/password-reset/', ForgotPasswordView.as_view(), name='password_reset'),
    path('api/logout/', LogoutView.as_view(), name='logout'),
]