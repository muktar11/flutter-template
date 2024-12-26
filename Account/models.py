from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.exceptions import ValidationError

class CustomUserManager(BaseUserManager):
    def create_user(self, phone, password=None, **extra_fields):
        if not phone:
            raise ValueError('The Phone number must be set')

        user = self.model(phone=phone, **extra_fields)
        user.set_password(password)  # Hash the password
        user.save(using=self._db)
        return user

    def create_superuser(self, phone, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user( phone, password, **extra_fields)



class CustomUser(AbstractUser):
    first_name = models.CharField(max_length=255, blank=True, null=True)
    last_name = models.CharField(max_length=255, blank=True, null=True)
    username = models.CharField(max_length=255, blank=True, null=True)
    email = models.EmailField(max_length=255, blank=True, null=True, unique=True)
    phone = models.CharField(max_length=15, unique=True)
    image_url = models.FileField(max_length=255,blank=True,null=True, default='defaults/icons.png')
    two_factor_authentication =  models.BooleanField(default=False)
    two_factor_auth_code = models.IntegerField(default=0)
    two_factor_auth_code_expiration = models.DateTimeField(blank=True, null=True)  # Expiration time for 2FA code
    objects = CustomUserManager()  # Use the custom user manager
    USERNAME_FIELD = 'phone'  # Set phone as the username field

    def __str__(self):
        return self.phone

class Profile(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    user_id = models.IntegerField(blank=True, null=True)
    parent = models.ForeignKey(CustomUser, on_delete=models.CASCADE, blank=True, null=True, related_name='profile')
    followers = models.ManyToManyField('self', symmetrical=False, related_name='following', blank=True)    
    enable_notifications = models.BooleanField(default=True)
    make_profile_public = models.BooleanField(default=True)
    show_online_status =  models.BooleanField(default=True)

# Signal to create Profile when a new CustomUser is created
@receiver(post_save, sender=CustomUser)
def create_profile(sender, instance, created, **kwargs):
    if created:
        # Create a Profile and inherit values from the CustomUser
        Profile.objects.create(
            parent=instance,
            user_id=instance.id,
        )


# Update the profile only if a Profile object exists for the CustomUser
@receiver(post_save, sender=CustomUser)
def save_profile(sender, instance, **kwargs):
    profiles = instance.profile.all()
    if profiles.exists():
        for profile in profiles:
            # Sync profile fields with the CustomUser instance
            profile.username = instance.username
            profile.email = instance.email
            profile.phone = instance.phone
            profile.save()

    def __str__(self):
        return self.user_id

'''
class ChatChannel(models.Model):
    participants = models.ManyToManyField(CustomUser)  # Link participants (users) to the channel
    name = models.CharField(max_length=255, unique=True)  # The name of the channel, should be unique for each pair

    def __str__(self):
        return self.name

    @classmethod
    def create_channel(cls, user1, user2):
        # Ensure the channel is created only once between two users
        if user1 == user2:
            raise ValueError("A user cannot chat with themselves.")

        # Check if a channel already exists between these two users
        existing_channel = cls.objects.filter(participants__in=[user1, user2]).distinct()

        # Ensure the channel has exactly 2 participants: user1 and user2
        for channel in existing_channel:
            if channel.participants.count() == 2 and user1 in channel.participants.all() and user2 in channel.participants.all():
                return channel  # Return the existing channel

        # Otherwise, create a new channel
        channel_name = f"{min(user1.id, user2.id)}-{max(user1.id, user2.id)}"  # Unique name based on user IDs
        new_channel = cls.objects.create(name=channel_name)
        new_channel.participants.set([user1, user2])  # Add both users to the channel
        return new_channel
'''

from channels.db import database_sync_to_async
'''
class ChatChannel(models.Model):
    participants = models.ManyToManyField(CustomUser)  # Link participants (users) to the channel
    name = models.CharField(max_length=255, unique=True)  # The name of the channel, should be unique for each pair

    def __str__(self):
        return self.name

    @classmethod
    @database_sync_to_async
    def create_channel(cls, user1, user2):
        # Ensure the channel is created only once between two users
        if user1 == user2:
            raise ValueError("A user cannot chat with themselves.")

        # Check if a channel already exists between these two users
        existing_channel = cls.objects.filter(participants__in=[user1, user2]).distinct()

        # Ensure the channel has exactly 2 participants: user1 and user2
        for channel in existing_channel:
            if channel.participants.count() == 2 and user1 in channel.participants.all() and user2 in channel.participants.all():
                return channel  # Return the existing channel

        # Otherwise, create a new channel
        channel_name = f"{min(user1.id, user2.id)}-{max(user1.id, user2.id)}"  # Unique name based on user IDs
        new_channel = cls.objects.create(name=channel_name)
        new_channel.participants.set([user1, user2])  # Add both users to the channel
        return new_channel
'''

class ChatChannel(models.Model):
    name = models.CharField(max_length=255, unique=True)
    participants = models.ManyToManyField(CustomUser, related_name="channels")

    @classmethod
    def create_channel(cls, user1, user2):
        # Ensure the users are not the same
        if user1 == user2:
            raise ValueError("Cannot create a channel with the same user.")

        # Check if a channel already exists
        channel_name = f"{min(user1.id, user2.id)}-{max(user1.id, user2.id)}"
        channel, created = cls.objects.get_or_create(name=channel_name)
        if created:
            channel.participants.add(user1, user2)
        return channel


    def __str__(self):
        return self.name

class ChatMessage(models.Model):
    channel = models.ForeignKey(ChatChannel, on_delete=models.CASCADE, related_name="messages")  # Corrected related_name
    sender = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="sent_messages")
    recipient = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="received_messages")
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    delivered = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.sender.username} -> {self.recipient.username}"

class Publish(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    parent = models.ForeignKey(CustomUser, models.CASCADE, blank=True, null=True)
    author = models.CharField(max_length=255, blank=True, null=True)
    email = models.CharField(max_length=255, blank=True, null=True)
    phone = models.CharField(max_length=255, blank=True, null=True)
    organization = models.CharField(max_length=255, blank=True, null=True)
    submission_type = models.CharField(max_length=255, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    short_description = models.CharField(max_length=255, blank=True, null=True)
    key_features_and_goals = models.CharField(max_length=255, blank=True, null=True)
    target_audience = models.CharField(max_length=255, blank=True, null=True)
    development_stage = models.CharField(max_length=255, blank=True, null=True)
    amount_needed = models.CharField(max_length=255, blank=True, null=True)
    how_will_funds_will_be_used = models.CharField(max_length=255, blank=True, null=True)
    market_overview = models.CharField(max_length=255, blank=True, null=True)
    competitors = models.CharField(max_length=255, blank=True, null=True)
    potential_user_impact = models.CharField(max_length=255, blank=True, null=True)
    uniqueness = models.CharField(max_length=255, blank=True, null=True)
    no_of_photos = models.IntegerField(default=0, blank=True, null=True)  # Changed to IntegerField
    no_of_videos = models.IntegerField(default=0, blank=True, null=True)  # Changed to IntegerField
    created_at = models.DateTimeField(auto_now=True)
    def __str__(self):
        return self.title

# Model for storing photos
class Photo(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    parent = models.ForeignKey(Publish, related_name='photos', on_delete=models.CASCADE)
    image_url = models.FileField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Photo for {self.parent.title}"

# Model for storing videos
class Video(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    parent = models.ForeignKey(Publish, related_name='videos', on_delete=models.CASCADE)
    video_url = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now=True)
    def __str__(self):
        return f"Video for {self.parent.title}"

class LikePublish(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    user = models.ForeignKey(CustomUser, related_name='user', on_delete=models.CASCADE)
    parent = models.ForeignKey(Publish, related_name='likes', on_delete=models.CASCADE)
    likes = models.BooleanField(default=False, blank=True, null=True)
    created_at = models.DateTimeField(auto_now=True)    

    def __str__(self):
        return f"Like for {self.parent.author}"

class RatePublish(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    user = models.ForeignKey(CustomUser, related_name='rater', on_delete=models.CASCADE)
    parent = models.ForeignKey(Publish, related_name='rate', on_delete=models.CASCADE)
    no_of_rating = models.IntegerField(default=0, blank=True, null=True)
    rate = models.BooleanField(default=False, blank=True, null=True)
    created_at = models.DateTimeField(auto_now=True)    

class Invest(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    parent = models.ForeignKey(CustomUser, models.CASCADE, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    budget = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    category = models.CharField(max_length=255, blank=True, null=True)
    investment_type = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now=True)  

class LikeInvest(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    user = models.ForeignKey(CustomUser, related_name='like_invest', on_delete=models.CASCADE)
    parent = models.ForeignKey(Invest, related_name='likes', on_delete=models.CASCADE)
    likes = models.BooleanField(default=False, blank=True, null=True)
    created_at = models.DateTimeField(auto_now=True)    

    def __str__(self):
        return f"Like for {self.parent.title}"


class RateInvest(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    user = models.ForeignKey(CustomUser, related_name='rate_invest', on_delete=models.CASCADE)
    parent = models.ForeignKey(Invest, related_name='rate', on_delete=models.CASCADE)
    no_of_rating = models.IntegerField(default=0, blank=True, null=True)
    rate = models.BooleanField(default=False, blank=True, null=True)
    created_at = models.DateTimeField(auto_now=True)
    

class Settings(models.Model):
    _id = models.AutoField(primary_key=True, editable=False)
    parent = models.ForeignKey(CustomUser, models.CASCADE, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    enable_notifications = models.BooleanField(max_length=255, blank=True, null=True)
    enable_dark_mode = models.BooleanField(max_length=255, blank=True, null=True)
    make_profile_public = models.BooleanField(max_length=255, blank=True, null=True)
    show_online_status = models.BooleanField(max_length=255, blank=True, null=True)
    two_factor_authentication = models.BooleanField(max_length=255, blank=True, null=True)