from django.db import models
from django.contrib.auth.models import User
from django.contrib.postgres.fields import ArrayField

# Create your models here.

class Alumni(models.Model):
    name = models.CharField(max_length=255)
    phone = models.CharField(max_length=20, unique=True)
    email = models.EmailField(unique=True)
    soc_poc = models.CharField(max_length=255)  # SOC Point of Contact
    availability = models.CharField(max_length=50, default='Online')
    time_to_contact_from = models.TimeField(default='00:00:00')
    time_to_contact_to = models.TimeField(default='23:59:59')
    country = models.CharField(max_length=255, null=True, default='UK')
    prior_course = models.CharField(max_length=255, null=True, blank=True)
    year_of_graduation = models.IntegerField()
    company = models.CharField(max_length=255, null=True, default='N/A')
    area_of_expertise = ArrayField(models.CharField(max_length=255), default=list)

    def __str__(self):
        return self.name

class Event(models.Model):
    name = models.CharField(max_length=255)
    date = models.DateField()
    time = models.TimeField()
    #area_of_interest = models.CharField(max_length=255)
    description = models.TextField(max_length=1000)

    def __str__(self):
        return self.name

class AlumniEvent(models.Model):
    alumni = models.ForeignKey(Alumni, on_delete=models.CASCADE)
    event = models.ForeignKey(Event, on_delete=models.CASCADE)
    attendance_status = models.BooleanField(default=False)
    attended_on = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.alumni.name} - {self.event.name}"
    
class PreviousContact(models.Model):
    alumni = models.ForeignKey(Alumni, on_delete=models.CASCADE)
    contacted_by = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.DateField()
    mode_of_contact = models.CharField(max_length=255)
    description = models.TextField()

    def __str__(self):
        return f"{self.alumni.name} - {self.contacted_by} - {self.mode_of_contact} - {self.date}"