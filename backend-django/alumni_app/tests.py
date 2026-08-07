from datetime import date, time

from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth.models import User
from alumni_app.serializers import RegisterSerializer, AlumniSerializer
from alumni_app.models import Alumni, Event, AlumniEvent, PreviousContact

class RegisterViewTest(APITestCase):
    def test_register_user(self):
        url = reverse('register')
        data = {
            'username': 'testuser',
            'password': 'testpassword',
            'password2': 'testpassword',
            'email': 'testuser@example.com'
        }
        response = self.client.post(url, data, format='json')
        print(response.data)  # Debugging line
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(User.objects.count(), 1)
        self.assertEqual(User.objects.get().username, 'testuser')

class CustomTokenObtainPairViewTest(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='testpassword')

    def test_obtain_token(self):
        url = reverse('token_obtain_pair')
        data = {
            'username': 'testuser',
            'password': 'testpassword'
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)
        self.assertIn('refresh', response.data)

class ForgotPasswordViewTest(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', email='testuser@example.com', password='testpassword')

    def test_forgot_password(self):
        url = reverse('password_reset')
        data = {
            'email': 'testuser@example.com'
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('message', response.data)

    def test_forgot_password_user_not_found(self):
        url = reverse('password_reset')
        data = {
            'email': 'nonexistent@example.com'
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertIn('error', response.data)

class RegisterSerializerTest(TestCase):
    def test_valid_data(self):
        data = {
            'username': 'testuser',
            'email': 'testuser@example.com',
            'password': 'testpassword',
            'password2': 'testpassword'
        }
        serializer = RegisterSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        user = serializer.save()
        self.assertEqual(user.username, 'testuser')
        self.assertEqual(user.email, 'testuser@example.com')
        self.assertTrue(user.check_password('testpassword'))

    def test_passwords_do_not_match(self):
        data = {
            'username': 'testuser',
            'email': 'testuser@example.com',
            'password': 'testpassword',
            'password2': 'differentpassword'
        }
        serializer = RegisterSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('password', serializer.errors)

    def test_missing_fields(self):
        data = {
            'username': 'testuser',
            'password': 'testpassword',
            'password2': 'testpassword'
            }
        serializer = RegisterSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('email', serializer.errors)


def valid_alumni_data(**overrides):
    data = {
        'name': 'Test Alumni',
        'phone': '1234567890',
        'email': 'alumni@example.com',
        'soc_poc': 'Jane POC',
        'year_of_graduation': 2020,
    }
    data.update(overrides)
    return data


class AlumniSerializerTest(TestCase):
    def test_phone_with_non_digits_is_rejected(self):
        serializer = AlumniSerializer(data=valid_alumni_data(phone='+44987654321'))
        self.assertFalse(serializer.is_valid())
        self.assertIn('phone', serializer.errors)

    def test_phone_with_digits_only_is_accepted(self):
        serializer = AlumniSerializer(data=valid_alumni_data(phone='44987654321'))
        self.assertTrue(serializer.is_valid(), serializer.errors)

    def test_area_of_expertise_defaults_to_empty_list_when_omitted(self):
        data = valid_alumni_data()
        self.assertNotIn('area_of_expertise', data)
        serializer = AlumniSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        alumni = serializer.save()
        self.assertEqual(alumni.area_of_expertise, [])


class AlumniViewSetTest(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='staff', password='testpass')
        self.alumni = Alumni.objects.create(**valid_alumni_data(
            phone='1112223333', email='existing@example.com',
        ))

    def test_list_requires_authentication(self):
        url = reverse('alumni-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_list_alumni_when_authenticated(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get(reverse('alumni-list'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_create_alumni(self):
        self.client.force_authenticate(user=self.user)
        data = valid_alumni_data(phone='9998887777', email='new@example.com')
        response = self.client.post(reverse('alumni-list'), data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Alumni.objects.count(), 2)

    def test_retrieve_alumni(self):
        self.client.force_authenticate(user=self.user)
        url = reverse('alumni-detail', kwargs={'pk': self.alumni.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['name'], self.alumni.name)

    def test_update_alumni(self):
        self.client.force_authenticate(user=self.user)
        url = reverse('alumni-detail', kwargs={'pk': self.alumni.pk})
        data = valid_alumni_data(
            name='Updated Name', phone=self.alumni.phone, email=self.alumni.email,
        )
        response = self.client.put(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.alumni.refresh_from_db()
        self.assertEqual(self.alumni.name, 'Updated Name')

    def test_delete_alumni(self):
        self.client.force_authenticate(user=self.user)
        url = reverse('alumni-detail', kwargs={'pk': self.alumni.pk})
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(Alumni.objects.count(), 0)


class PreviousContactViewSetTest(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='staff', password='testpass')
        self.other_user = User.objects.create_user(username='other', password='testpass')
        self.alumni = Alumni.objects.create(**valid_alumni_data(
            phone='1112223333', email='a@example.com',
        ))
        self.other_alumni = Alumni.objects.create(**valid_alumni_data(
            phone='4445556666', email='b@example.com',
        ))
        self.client.force_authenticate(user=self.user)

    def test_create_ignores_client_supplied_contacted_by(self):
        data = {
            'alumni': self.alumni.pk,
            'contacted_by': self.other_user.pk,  # read-only: should be ignored
            'date': '2024-01-01',
            'mode_of_contact': 'Email',
            'description': 'Checked in',
        }
        response = self.client.post(reverse('previous-contact-list'), data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        contact = PreviousContact.objects.get(pk=response.data['id'])
        self.assertEqual(contact.contacted_by, self.user)

    def test_list_filters_by_alumni_and_orders_most_recent_first(self):
        PreviousContact.objects.create(
            alumni=self.alumni, contacted_by=self.user, date=date(2024, 1, 1),
            mode_of_contact='Email', description='First',
        )
        PreviousContact.objects.create(
            alumni=self.alumni, contacted_by=self.user, date=date(2024, 2, 1),
            mode_of_contact='Phone', description='Second',
        )
        PreviousContact.objects.create(
            alumni=self.other_alumni, contacted_by=self.user, date=date(2024, 1, 15),
            mode_of_contact='Phone', description='Not this alumni',
        )

        response = self.client.get(reverse('previous-contact-list'), {'alumni': self.alumni.pk})

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        results = response.data.get('results', response.data)
        self.assertEqual(len(results), 2)
        self.assertEqual(results[0]['description'], 'Second')  # most recent first
        self.assertEqual(results[1]['description'], 'First')


class AlumniEventViewSetTest(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='staff', password='testpass')
        self.alumni = Alumni.objects.create(**valid_alumni_data(
            phone='1112223333', email='a@example.com',
        ))
        self.other_alumni = Alumni.objects.create(**valid_alumni_data(
            phone='4445556666', email='b@example.com',
        ))
        self.event = Event.objects.create(
            name='Tech Conference', date=date(2024, 5, 1), time=time(10, 0),
            description='A conference',
        )
        self.client.force_authenticate(user=self.user)

    def test_create_attendance_response_nests_event_detail(self):
        data = {
            'alumni': self.alumni.pk,
            'event': self.event.pk,
            'attendance_status': True,
            'attended_on': '2024-05-01T10:00:00',
        }
        response = self.client.post(reverse('alumni-event-list'), data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['event_detail']['name'], 'Tech Conference')

    def test_list_filters_by_alumni(self):
        AlumniEvent.objects.create(
            alumni=self.alumni, event=self.event, attendance_status=True,
            attended_on='2024-05-01T10:00:00',
        )
        AlumniEvent.objects.create(
            alumni=self.other_alumni, event=self.event, attendance_status=True,
            attended_on='2024-05-01T10:00:00',
        )

        response = self.client.get(reverse('alumni-event-list'), {'alumni': self.alumni.pk})

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        results = response.data.get('results', response.data)
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['alumni'], self.alumni.pk)