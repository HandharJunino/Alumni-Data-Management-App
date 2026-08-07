from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken
from .models import Alumni, Event, AlumniEvent, PreviousContact
from django.contrib.auth.models import User

class AlumniSerializer(serializers.ModelSerializer):
    area_of_expertise = serializers.ListField(
        child=serializers.CharField(),
        allow_empty=True,
        required=False,
        default=list
    )

    class Meta:
        model = Alumni
        fields = ['id', 'name', 'phone', 'email', 'soc_poc', 'availability',
                 'time_to_contact_from', 'time_to_contact_to', 'country',
                 'prior_course', 'year_of_graduation',
                 'company', 'area_of_expertise']

    def validate_phone(self, value):
        if not value.isdigit():
            raise serializers.ValidationError("Phone number must contain only digits")
        return value

    def to_internal_value(self, data):
        # Ensure area_of_expertise is always a list
        if 'area_of_expertise' not in data:
            data = data.copy()
            data['area_of_expertise'] = []
        return super().to_internal_value(data)
    
    def create(self, validated_data):
        # Get the highest existing ID
        highest_id = Alumni.objects.all().order_by('-id').first()
        if highest_id:
            # If records exist, increment the highest ID by 1
            validated_data['id'] = highest_id.id + 1
        else:
            # If no records exist, start with ID 1
            validated_data['id'] = 1
            
        return super().create(validated_data)

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = ['id', 'name', 'date', 'time', 'description']

class AlumniEventSerializer(serializers.ModelSerializer):
    event_detail = EventSerializer(source='event', read_only=True)

    class Meta:
        model = AlumniEvent
        fields = ['id', 'alumni', 'event', 'event_detail', 'attendance_status', 'attended_on']

class RegisterSerializer(serializers.ModelSerializer):
    password2 = serializers.CharField(write_only=True)
    email = serializers.EmailField(required=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password2']
        extra_kwargs = {'password': {'write_only': True}}

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Passwords must match."})
        return data

    def create(self, validated_data):
        user = User(
            email=validated_data['email'],
            username=validated_data['username']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user
    
class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField()

    def validate(self, attrs):
        self.token = attrs['refresh']
        return attrs

    def save(self, **kwargs):
        try:
            RefreshToken(self.token).blacklist()
        except Exception:
            raise serializers.ValidationError('Invalid token')
    
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class PreviousContactSerializer(serializers.ModelSerializer):
    contacted_by = UserSerializer(read_only=True)  # Nested serializer for User
    alumni_name = serializers.CharField(source='alumni.name', read_only=True)  # Get alumni name

    class Meta:
        model = PreviousContact
        fields = ['id', 'alumni', 'alumni_name', 'contacted_by', 'date', 
                 'mode_of_contact', 'description']
        read_only_fields = ['contacted_by']