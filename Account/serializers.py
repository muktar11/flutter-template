from django.contrib.auth.password_validation import validate_password
from .models import CustomUser, Profile,Publish, Photo, Video, Invest, Settings, LikePublish, RatePublish, LikeInvest, RateInvest
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.tokens import RefreshToken 
from rest_framework import serializers
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from django.contrib.auth.models import update_last_login
from django.utils.translation import gettext_lazy as _
from .models import CustomUser
from django.db.models import Sum, Avg
 
class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    first_name = serializers.CharField(write_only=True)
    last_name = serializers.CharField(write_only=True)
    username = serializers.CharField(write_only=True)
    image_url = serializers.FileField()
    phone = serializers.CharField(write_only=True)
    password = serializers.CharField(write_only=True)
    access = serializers.CharField(read_only=True)
    refresh = serializers.CharField(read_only=True)
    def validate(self, attrs):
        phone = attrs.get('phone')
        password = attrs.get('password')

        if phone and password:
            user = authenticate(request=self.context.get('request'), phone=phone, password=password)

            if not user:
                raise serializers.ValidationError(_('Invalid phone number or password.'))

            if not user.is_active:
                raise serializers.ValidationError(_('User account is disabled.'))

            # If authentication is successful, generate token
            refresh = RefreshToken.for_user(user)
            data = {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user_id': user.id,
                'phone': user.phone,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'email': user.email,
                'image_url': user.image_url
            }

            update_last_login(None, user)
            return data

        raise serializers.ValidationError(_('Phone number and password are required.'))

from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.utils.translation import gettext_lazy as _

class ChangePasswordSerializer(serializers.Serializer):
    new_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    confirm_new_password = serializers.CharField(write_only=True, required=True)

    def validate(self, attrs):
        # Ensure new passwords match
        if attrs['new_password'] != attrs['confirm_new_password']:
            raise serializers.ValidationError(_("The new passwords do not match."))
        return attrs

    def save(self, user):
        user.set_password(self.validated_data['new_password'])
        user.save()
        return user

import random
from django.core.mail import send_mail
from django.conf import settings
from datetime import datetime, timedelta
from django.utils.timezone import now
from datetime import timedelta
from django.conf import settings
from urllib.parse import urljoin



class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    phone = serializers.CharField(write_only=True)
    password = serializers.CharField(write_only=True)
    access = serializers.CharField(read_only=True)
    refresh = serializers.CharField(read_only=True)
    two_factor_required = serializers.BooleanField(read_only=True)

    def validate(self, attrs):
        phone = attrs.get('phone')
        password = attrs.get('password')

        if phone and password:
            user = authenticate(request=self.context.get('request'), phone=phone, password=password)

            if not user:
                raise serializers.ValidationError(_('Invalid phone number or password.'))

            if not user.is_active:
                raise serializers.ValidationError(_('User account is disabled.'))

            if user.two_factor_authentication:
                # Generate a random 6-digit 2FA code
                two_factor_code = random.randint(100000, 999999)
                user.two_factor_auth_code = two_factor_code
                user.two_factor_auth_code_expiration = now() + timedelta(hours=1)
                user.save()

                # Send 2FA code via email
                '''
                send_mail(
                    subject='Your Two-Factor Authentication Code',
                    message=f'Your 2FA code is: {two_factor_code}',
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[user.email],
                )
                '''


                return {
                    'two_factor_required': True,
                    'user_id': user.id,
                    'phone': user.phone,
                }

            # If 2FA is not enabled, proceed to generate tokens
            refresh = RefreshToken.for_user(user)
            request = self.context.get('request')
            profile_pic = user.image_url
            if profile_pic:
                if isinstance(profile_pic, bytes):
                    profile_pic = profile_pic.decode('utf-8')
                elif not isinstance(profile_pic, str):
                    profile_pic = str(profile_pic)

                # Ensure the URL is correctly constructed
                profile_pic = urljoin(settings.MEDIA_URL, profile_pic)
                profile_pic = request.build_absolute_uri(profile_pic) if request else profile_pic
            else:
                profile_pic = None  # Handle case where profile_pic is None

            return {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user_id': user.id,
                'phone': user.phone,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'email': user.email,
                'username':user.username,
                'profile_pic': profile_pic,
                'two_factor_required': False,
            }

        raise serializers.ValidationError(_('Phone number and password are required.'))

class TwoFactorAuthSerializer(serializers.Serializer):
    phone = serializers.CharField(write_only=True)
    code = serializers.IntegerField(write_only=True)
    access = serializers.CharField(read_only=True)
    refresh = serializers.CharField(read_only=True)

    def validate(self, attrs):
        phone = attrs.get('phone')
        code = attrs.get('code')

        try:
            user = CustomUser.objects.get(phone=phone)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError(_('Invalid phone number.'))

        if user.two_factor_auth_code != code:
            raise serializers.ValidationError(_('Invalid two-factor authentication code.'))

        # Reset 2FA code after successful validation
        user.two_factor_auth_code = 0
        user.save()

        # Generate tokens
        refresh = RefreshToken.for_user(user)
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'user_id': user.id,
            'phone': user.phone,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'username':user.username,
            'image_url': user.image_url,
        }

class DeleteUserSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)

    def validate_phone(self, value):
        try:
            user = get_user_model().objects.get(phone=value)
        except get_user_model().DoesNotExist:
            raise ValidationError("User with this phone number does not exist.")
        return value

class CustomUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = [
            'id','first_name', 'last_name', 'username', 'email', 
            'phone', 'image_url', 'two_factor_authentication'
        ]
        read_only_fields = ['phone']  # Prevent phone from being updated


class RegisterStaffSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = CustomUser
        fields = ('first_name', 'last_name', 'phone', 
        'username', 'password', 'password2', 'email')

    def validate(self, attrs):
        # Check if passwords match
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})

        # Validate that phone and email are unique (if not already enforced in the model)
        if CustomUser.objects.filter(phone=attrs['phone']).exists():
            raise serializers.ValidationError({"phone": "A user with this phone number already exists."})
        if CustomUser.objects.filter(email=attrs['email']).exists():
            raise serializers.ValidationError({"email": "A user with this email already exists."})
        return attrs

    def create(self, validated_data):
        try:
            # Remove password2 as it's not part of the model
            validated_data.pop('password2')
            # Create the user
            user = CustomUser.objects.create(
                first_name=validated_data['first_name'],
                last_name=validated_data['last_name'],
                phone=validated_data['phone'],
                username=validated_data['username'],
                email=validated_data['email'],
            )
            user.set_password(validated_data['password'])
            user.save()
            return user
        except Exception as e:
            raise serializers.ValidationError({"detail": f"An error occurred while creating the user: {str(e)}"})



from django.conf import settings
from django.templatetags.static import static
class PhotoSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Photo
        fields = ['_id', 'image_url']

    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image_url and request:
            return request.build_absolute_uri(obj.image_url.url)
        return None



class FollowerFollowingSerializer(serializers.ModelSerializer):
    user = CustomUserSerializer(source='parent', read_only=True)

    class Meta:
        model = Profile
        fields = [
            '_id',
            'user',
            'enable_notifications',
            'make_profile_public',
            'show_online_status',
        ]

class FollowSerializer(serializers.ModelSerializer):
    followers = FollowerFollowingSerializer(many=True, read_only=True)
    following = FollowerFollowingSerializer(many=True, read_only=True)

    class Meta:
        model = Profile
        fields = [
            '_id',
            'user_id',
            'followers',
            'following',
            'enable_notifications',
            'make_profile_public',
            'show_online_status',
        ]
        
# Serializer for Video model
class VideoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Video
        fields = ['_id', 'video_url']


class LikePublishSerializer(serializers.ModelSerializer):
    class Meta:
        model = LikePublish
        fields = ['_id', 'parent', 'user', 'likes', 'created_at']

class RatePublishSerializer(serializers.ModelSerializer):
    class Meta:
        model = RatePublish
        fields= ['_id', 'parent','no_of_rating', 'rate', 'created_at']


class LikeInvestSerializer(serializers.ModelSerializer):
    class Meta:
        model = LikeInvest
        fields = ['_id', 'parent', 'user', 'likes', 'created_at']

class RateInvestSerializer(serializers.ModelSerializer):
    class Meta:
        model = RateInvest
        fields= ['_id', 'parent','no_of_rating', 'rate', 'created_at']


class PublishSerializer(serializers.ModelSerializer):
    # Read-only nested fields for photo and video details
    photos_detail = PhotoSerializer(many=True, read_only=True)
    videos_detail = VideoSerializer(many=True, read_only=True)
    like_count = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()
    # Handle incoming photo and video files
    photos = serializers.ListField(child=serializers.ImageField(), write_only=True)
    videos = serializers.ListField(child=serializers.CharField(), write_only=True)

    class Meta:
        model = Publish
        fields = [
            '_id', 'parent', 'author', 'email', 'phone', 'organization', 'submission_type',
            'title', 'short_description', 'key_features_and_goals', 'target_audience', 
            'development_stage', 'amount_needed', 'how_will_funds_will_be_used', 
            'market_overview', 'competitors', 'potential_user_impact', 'uniqueness', 
            'no_of_photos', 'no_of_videos', 'photos', 'videos', 'photos_detail', 'videos_detail',
            'created_at', 'like_count', 'average_rating'
        ]

    def get_like_count(self, obj):
        # Count only true likes
        return obj.likes.filter(likes=True).count()

    def get_average_rating(self, obj):
        ratings = obj.rate.filter(no_of_rating__isnull=False)
        if ratings.exists():
            total_ratings = sum(rating.no_of_rating for rating in ratings)
            average = total_ratings / ratings.count()
            return round(average, 2)
        return 0

    def create(self, validated_data):
        # Extract photos and videos from the validated data
        photos_data = validated_data.pop('photos', [])
        videos_data = validated_data.pop('videos', [])

        # Create the Publish object
        publish = Publish.objects.create(**validated_data)

        # Save photos
        for photo in photos_data:
            Photo.objects.create(parent=publish, image_url=photo)

        # Save videos
        for video_url in videos_data:
            Video.objects.create(parent=publish, video_url=video_url)

        return publish




class PublishRetrieveSerializer(serializers.ModelSerializer):
    # Nested serializers to show details of related Photo and Video instances
    photos_detail = PhotoSerializer(many=True, read_only=True, source='photos')  # photos related name
    videos_detail = VideoSerializer(many=True, read_only=True, source='videos')  # videos related name
    like_count = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()
    total_rating = serializers.SerializerMethodField()
    # Handle incoming photo and video files
    photos = serializers.ListField(child=serializers.ImageField(), write_only=True)
    videos = serializers.ListField(child=serializers.CharField(), write_only=True)


    class Meta:
        model = Publish
        fields = [
            '_id', 'parent', 'author', 'email', 'phone', 'organization', 'submission_type',
            'title', 'short_description', 'key_features_and_goals', 'target_audience', 
            'development_stage', 'amount_needed', 'how_will_funds_will_be_used', 
            'market_overview', 'competitors', 'potential_user_impact', 'uniqueness', 
            'no_of_photos', 'no_of_videos', 'photos', 'videos', 'photos_detail', 'videos_detail',
            'created_at', 'like_count', 'average_rating', 'total_rating'
        ]

    def get_like_count(self, obj):
        # Count only true likes
        return obj.likes.filter(likes=True).count()

    def get_average_rating(self, obj):
        # Calculate the average of no_of_rating for the Publish instance
        average = obj.rate.aggregate(Avg('no_of_rating')).get('no_of_rating__avg')
        return float(round(average, 2)) if average is not None else 0.0

    def get_total_rating(self, obj):
        # Calculate the sum of no_of_rating for the Publish instance
        total = obj.rate.aggregate(Sum('no_of_rating')).get('no_of_rating__sum')
        return float(total) if total is not None else 0.0



    def create(self, validated_data):
        # Extract photos and videos from the validated data
        photos_data = validated_data.pop('photos', [])
        videos_data = validated_data.pop('videos', [])

        # Create the Publish object
        publish = Publish.objects.create(**validated_data)

        # Save photos
        for photo in photos_data:
            Photo.objects.create(parent=publish, image_url=photo)

        # Save videos
        for video_url in videos_data:
            Video.objects.create(parent=publish, video_url=video_url)

        return publish





class InvestRetrieveSerializer(serializers.ModelSerializer):
    like_count = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()
    total_rating = serializers.SerializerMethodField()

    class Meta:
        model = Invest
        fields = [
            '_id', 'parent', 'title', 'budget', 'description', 'category', 'investment_type',
            'created_at', 'like_count', 'average_rating', 'total_rating'
        ]

    def get_like_count(self, obj):
        # Count only true likes
        return obj.likes.filter(likes=True).count()

    def get_average_rating(self, obj):
        # Calculate the average of no_of_rating for the Publish instance
        average = obj.rate.aggregate(Avg('no_of_rating')).get('no_of_rating__avg')
        return float(round(average, 2)) if average is not None else 0.0

    def get_total_rating(self, obj):
        # Calculate the sum of no_of_rating for the Publish instance
        total = obj.rate.aggregate(Sum('no_of_rating')).get('no_of_rating__sum')
        return float(total) if total is not None else 0.0


        return publish


# Serializer for Invest model
class InvestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Invest
        fields = ['_id', 'parent', 'title', 'budget', 'description', 'category', 'investment_type']

# Serializer for Settings model
class SettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Settings
        fields = '__all__'


class NestedProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = '__all__'



class ProfileSerializer(serializers.ModelSerializer):
    followers = NestedProfileSerializer(many=True, read_only=True)
    following = NestedProfileSerializer(many=True, read_only=True)
    two_factor_authentication = serializers.SerializerMethodField()
    no_of_followers = serializers.SerializerMethodField()
    no_of_following = serializers.SerializerMethodField()

    class Meta:
        model = Profile
        fields = ['_id', 'user_id',  'followers', 'following', 
          'no_of_followers', 'no_of_following','two_factor_authentication',
         'enable_notifications', 'make_profile_public', 'show_online_status',
         ]

    def get_two_factor_authentication(self, obj):
            return obj.parent.two_factor_authentication if obj.parent else None    


    def get_no_of_followers(self, obj):
        return obj.followers.count()

    def get_no_of_following(self, obj):
        return obj.following.count()    



class ProfilesSerializer(serializers.ModelSerializer):
    user_id = serializers.SerializerMethodField()  # Dynamically fetch user_id from parent

    class Meta:
        model = Profile
        fields = ['_id', 'user_id', 'enable_notifications', 'make_profile_public', 'show_online_status']

    def get_user_id(self, obj):
        # Access the parent field directly
        return obj.parent.id if obj.parent else None
    

class CustomUserProfileSerializer(serializers.ModelSerializer):
    profile = ProfilesSerializer()  # Nested serializer for the Profile model

    class Meta:
        model = CustomUser
        fields = ['id', 'first_name', 'last_name', 'email', 'phone', 'image_url', 'profile']


class UserSuggestionWithProfileSerializer(serializers.ModelSerializer):
    profile = ProfilesSerializer( many=True)

    class Meta:
        model = CustomUser
        fields = ['id', 'first_name', 'last_name', 'username', 'email', 'phone', 'image_url', 'profile']

    
'''
class UserActivitySerializer(serializers.Serializer):
    publishes = PublishRetrieveSerializer(many=True)
    likes = serializers.SerializerMethodField()
    ratings = serializers.SerializerMethodField()
    investments = InvestRetrieveSerializer(many=True)
    like_invest = serializers.SerializerMethodField()
    like_ratings = serializers.SerializerMethodField

    # Updated get_likes method
    def get_likes(self, obj):
        likes = obj['likes']
        like_data = []
        for like in likes:
            publish = Publish.objects.filter(_id=like.parent._id).first()  # Use _id here
            like_data.append({
                '_id': like._id,
                'user': like.user.id,
                'likes': like.likes,
                'created_at': like.created_at,
                'publish': PublishRetrieveSerializer(publish).data if publish else None
            })
        return like_data

    # Updated get_likes method
    def get_likes(self, obj):
        likes = obj['likes']
        like_data = []
        for like in likes:
            publish = Publish.objects.filter(_id=like.parent._id).first()  # Use _id here
            like_data.append({
                '_id': like._id,
                'user': like.user.id,
                'likes': like.likes,
                'created_at': like.created_at,
                'publish': PublishRetrieveSerializer(publish).data if publish else None
            })
        return like_data
        
    # Updated get_ratings method
    def get_ratings(self, obj):
        ratings = obj['ratings']
        rating_data = []
        for rating in ratings:
            publish = Publish.objects.filter(_id=rating.parent._id).first()  # Use _id here
            rating_data.append({
                '_id': rating._id,
                'user': rating.user.id,
                'no_of_rating': rating.no_of_rating,
                'rate': rating.rate,
                'created_at': rating.created_at,
                'publish': PublishRetrieveSerializer(publish).data if publish else None
            })
        return rating_data


    def to_representation(self, instance):
        # Add user_id to the representation
        representation = super().to_representation(instance)
        representation['user_id'] = self.context.get('user').id
        return representation

'''



class UserActivitySerializer(serializers.Serializer):
    publishes = PublishRetrieveSerializer(many=True)
    likes = serializers.SerializerMethodField()
    ratings = serializers.SerializerMethodField()
    investments = InvestRetrieveSerializer(many=True)
    like_invest = serializers.SerializerMethodField()
    like_ratings = serializers.SerializerMethodField()
   

    def get_likes(self, obj):
        likes = obj['likes']
        like_data = []
        for like in likes:
            publish = Publish.objects.filter(_id=like.parent._id).first()
            like_data.append({
                '_id': like._id,
                'user': like.user.id,
                'likes': like.likes,
                'created_at': like.created_at,
                'publish': PublishRetrieveSerializer(publish).data if publish else None
            })
        return like_data

    def get_ratings(self, obj):
        ratings = obj['ratings']
        rating_data = []
        for rating in ratings:
            publish = Publish.objects.filter(_id=rating.parent._id).first()
            rating_data.append({
                '_id': rating._id,
                'user': rating.user.id,
                'no_of_rating': rating.no_of_rating,
                'rate': rating.rate,
                'created_at': rating.created_at,
                'publish': PublishRetrieveSerializer(publish).data if publish else None
            })
        return rating_data

   

    def get_like_invest(self, obj):
        like_investments = obj.get('like_investments', [])  # Use `get` to avoid KeyError
        like_invest_data = []
        for like_invest in like_investments:
            investment = Invest.objects.filter(_id=like_invest.parent._id).first()
            like_invest_data.append({
                '_id': like_invest._id,
                'user': like_invest.user.id,
                'likes': like_invest.likes,
                'created_at': like_invest.created_at,
                'investment': InvestRetrieveSerializer(investment).data if investment else None
            })
        return like_invest_data


    def get_like_ratings(self, obj):
        like_ratings = obj.get('like_ratings', [])  # Use .get() to avoid KeyError
        like_ratings_data = []
        
        for like_rating in like_ratings:
            rating = Rating.objects.filter(_id=like_rating.parent._id).first()
            like_ratings_data.append({
                '_id': like_rating._id,
                'user': like_rating.user.id,
                'likes': like_rating.likes,
                'created_at': like_rating.created_at,
                'rating': {
                    'rate': rating.rate if rating else None,
                    'no_of_rating': rating.no_of_rating if rating else None,
                    'created_at': rating.created_at if rating else None
                } if rating else None
            })
        
        return like_ratings_data


    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['user_id'] = self.context.get('user').id
        return representation

class UserFeedSerializer(serializers.Serializer):
    publish = PublishRetrieveSerializer(many=True)
    invest = InvestRetrieveSerializer(many=True)