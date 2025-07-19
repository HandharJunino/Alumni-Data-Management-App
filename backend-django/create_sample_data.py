#!/usr/bin/env python
import os
import sys
import django

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'alumni_project.settings')
django.setup()

from alumni_app.models import Alumni, Event
from datetime import date, time

def create_sample_data():
    # Create sample alumni
    alumni_data = [
        {
            'name': 'John Smith',
            'phone': '+44123456789',
            'email': 'john.smith@email.com',
            'soc_poc': 'Jane Doe',
            'availability': 'Online',
            'country': 'UK',
            'prior_course': 'Computer Science',
            'year_of_graduation': 2020,
            'company': 'Tech Corp',
            'area_of_expertise': ['Software Development', 'Machine Learning']
        },
        {
            'name': 'Sarah Johnson',
            'phone': '+44987654321',
            'email': 'sarah.johnson@email.com',
            'soc_poc': 'Bob Wilson',
            'availability': 'In-person',
            'country': 'UK',
            'prior_course': 'Business Administration',
            'year_of_graduation': 2019,
            'company': 'Business Solutions Ltd',
            'area_of_expertise': ['Project Management', 'Leadership']
        },
        {
            'name': 'Mike Chen',
            'phone': '+44555123456',
            'email': 'mike.chen@email.com',
            'soc_poc': 'Lisa Brown',
            'availability': 'Online',
            'country': 'Canada',
            'prior_course': 'Data Science',
            'year_of_graduation': 2021,
            'company': 'Data Analytics Inc',
            'area_of_expertise': ['Data Analysis', 'Python Programming']
        }
    ]

    # Create sample events
    events_data = [
        {
            'name': 'Alumni Networking Event',
            'date': date(2025, 8, 15),
            'time': time(18, 0),
            'description': 'Join us for an evening of networking with fellow alumni.'
        },
        {
            'name': 'Career Development Workshop',
            'date': date(2025, 9, 10),
            'time': time(14, 0),
            'description': 'Learn about career advancement opportunities and industry trends.'
        },
        {
            'name': 'Tech Talk: AI in Business',
            'date': date(2025, 10, 5),
            'time': time(16, 30),
            'description': 'Explore how artificial intelligence is transforming modern business.'
        }
    ]

    print("Creating sample alumni...")
    for alumni_info in alumni_data:
        alumni, created = Alumni.objects.get_or_create(
            email=alumni_info['email'],
            defaults=alumni_info
        )
        if created:
            print(f"✓ Created alumni: {alumni.name}")
        else:
            print(f"• Alumni already exists: {alumni.name}")

    print("\nCreating sample events...")
    for event_info in events_data:
        event, created = Event.objects.get_or_create(
            name=event_info['name'],
            defaults=event_info
        )
        if created:
            print(f"✓ Created event: {event.name}")
        else:
            print(f"• Event already exists: {event.name}")

    print("\n🎉 Sample data creation completed!")
    print(f"Total Alumni: {Alumni.objects.count()}")
    print(f"Total Events: {Event.objects.count()}")

if __name__ == "__main__":
    create_sample_data()
