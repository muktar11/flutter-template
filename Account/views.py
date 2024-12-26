from django.shortcuts import render
from django.http import JsonResponse
from .models import CustomUser, RatePublish, Profile,Publish, Photo, Video, Invest, Settings, LikeInvest, RateInvest
from .serializers import  (MyTokenObtainPairSerializer,  ProfileSerializer,
CustomUserProfileSerializer, RegisterStaffSerializer,
ChangePasswordSerializer,
UserSuggestionWithProfileSerializer,
PublishSerializer, NestedProfileSerializer, 
PhotoSerializer, TwoFactorAuthSerializer, 
InvestRetrieveSerializer, CustomUserSerializer,
VideoSerializer,PublishRetrieveSerializer, 
UserActivitySerializer, InvestSerializer,
SettingsSerializer,LikeInvestSerializer,
RateInvestSerializer, DeleteUserSerializer, 
UserFeedSerializer, FollowSerializer)
from rest_framework import generics
from rest_framework.exceptions import NotFound
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken, AccessToken
from rest_framework import generics 
from rest_framework import status
from django.core.paginator import Paginator
from django.contrib.auth.hashers import make_password
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from rest_framework.permissions import AllowAny, IsAuthenticated
# Create your views here.
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
import json 
from django.http import JsonResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.generics import UpdateAPIView
from django.shortcuts import get_object_or_404
from .models import CustomUser
from .serializers import ChangePasswordSerializer
from django.utils.translation import gettext_lazy as _
from rest_framework_simplejwt.views import TokenRefreshView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework import permissions
from rest_framework.views import APIView
from rest_framework.exceptions import AuthenticationFailed
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser



class MyTokenObtainPairView(TokenObtainPairView):
    def post(self, request, *args, **kwargs):
        serializer = MyTokenObtainPairSerializer(data=request.data, context={'request': request})
        try:
            serializer.is_valid(raise_exception=True)
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        except serializers.ValidationError as e:
            return Response({'detail': e.detail}, status=status.HTTP_400_BAD_REQUEST)
            
      
class TokenRefreshViewCustom(APIView):
    def post(self, request):
        # Get the refresh token from the request
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response({"detail": "Refresh token is required."}, status=400)
        try:
            # Check if the refresh token is valid
            refresh = RefreshToken(refresh_token)
            # Generate a new access token
            access_token = str(refresh.access_token)
            return Response({
                "access": access_token,
            })
        except Exception as e:
            print(f"Error: {e}")  # Print the exception for debugging
            return Response({"detail": "Invalid refresh token."}, status=400)


class EditCustomUserView(UpdateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = CustomUserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        """
        Override to retrieve the user based on the user_id in the URL.
        """
        user_id = self.kwargs.get('user_id')  # Get the user_id from the URL
        return get_object_or_404(CustomUser, id=user_id)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', True)  # Allow partial updates
        instance = self.get_object()

        # Preprocess the data to leave fields as-is if they are null
        updated_data = request.data.copy()
        for field in ['username', 'email', 'first_name', 'last_name', 'phone', 'profile_pic', 'two_factor_required' ] :
            if field in updated_data and updated_data[field] is None:
                updated_data.pop(field)  # Remove null fields to leave them unchanged
        serializer = self.get_serializer(instance, data=updated_data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        # Serialize the updated instance
        updated_instance_serializer = self.get_serializer(instance)

        return Response({
            'message': 'Profile updated successfully',
            'updated_data': updated_instance_serializer.data
        }, status=status.HTTP_200_OK)

        
class TwoFactorAuthView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            serializer = TwoFactorAuthSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        except AuthenticationFailed as auth_error:
                # Handle expired or invalid token
                print("Authentication error:", auth_error)
                return Response(
                    {"detail": "Token expired. Please refresh your token."},
                    status=status.HTTP_401_UNAUTHORIZED,
                )
        except ValidationError as e:
                # If validation fails, print the error details
                print("Validation error:", e.detail)
                return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

class RegisterStaffView(APIView):
    permission_classes = (AllowAny,)
    serializer_class = RegisterStaffSerializer

    def post(self, request):
        try:
            # Validate and save user data
            serializer = self.serializer_class(data=request.data)
            serializer.is_valid(raise_exception=True)
            user = serializer.save()

            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)
            access_token = str(refresh.access_token)

            return Response({
                'message': 'User registered successfully',
                'user': RegisterStaffSerializer(user).data,
                'access_token': access_token,
            }, status=status.HTTP_201_CREATED)

        except ValidationError as ve:
            # Handle validation errors explicitly
            return Response({"errors": ve.detail}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            # Catch all other exceptions
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, user_id, *args, **kwargs):
        # Fetch user by ID
        user = get_object_or_404(CustomUser, id=user_id)

        # Serialize and validate the data
        serializer = ChangePasswordSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)
            return Response({'detail': _("Password changed successfully.")}, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class FollowersFollowingView(APIView):
    def get(self, request, user_id, *args, **kwargs):
        try:
            # Fetch the CustomUser using the provided user_id
            user = CustomUser.objects.get(id=user_id)

            # Fetch the Profile associated with this user
            profile = Profile.objects.get(parent=user)

            # Serialize the profile data
            serializer = FollowSerializer(profile)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except CustomUser.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
        except Profile.DoesNotExist:
            return Response({'error': 'Profile not found'}, status=status.HTTP_404_NOT_FOUND)
@api_view(['GET'])
@permission_classes([IsAuthenticated]) 
def get_channel_id(request):
    try:
        queryset = Channel.objects.all()
        serializer = ChannelSerializer(queryset, many=True, context={'request': request})
        return Response(serializer.data)
    except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
    except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([IsAuthenticated]) 
def create_profile(request):
    try:
        queryset = Profile.objects.all()
        serializer = ProfileSerializer(queryset, many=True, context={'request': request})
        return Response(serializer.data)
    except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
    except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
@api_view(['GET'])
@permission_classes([IsAuthenticated]) 
def get_profile(request, pk):
    try:
        profile = Profile.objects.get(user_id=pk)
        serializer = ProfileSerializer(profile, many=False, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Profile.DoesNotExist:
        return Response({'detail': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
    except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)


  #  permission_classes = [IsAuthenticated]
    #def get(self, request):
    #    user = request.user


class FollowUnfollowView(APIView):
   
    def post(self, request, user_id, profile_id, format=None):
        try:
            # Retrieve the current user's profile using user_id
            try:
                current_user_profile = Profile.objects.get(user_id=user_id)
            except Profile.DoesNotExist:
                return Response({"error": "Your profile is not found."}, status=status.HTTP_404_NOT_FOUND)

            # Retrieve the profile to follow/unfollow using profile_id
            try:
                profile_to_follow = Profile.objects.get(_id=profile_id)
            except Profile.DoesNotExist:
                return Response({"error": "The profile to follow/unfollow is not found."}, status=status.HTTP_404_NOT_FOUND)

            # Prevent a user from following/unfollowing themselves
            if profile_to_follow == current_user_profile:
                return Response({"error": "You cannot follow yourself."}, status=status.HTTP_400_BAD_REQUEST)
            # Handle follow/unfollow logic
            if profile_to_follow in current_user_profile.following.all():
                current_user_profile.following.remove(profile_to_follow)
                message = "Unfollowed successfully."
            else:
                current_user_profile.following.add(profile_to_follow)
                message = "Followed successfully."

            return Response({"message": message}, status=status.HTTP_200_OK)

        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, return the error details
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            # Catch any unexpected errors
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class ProfileSearchView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        try:
            # Get the query parameter
            query = request.query_params.get('query', '').strip()  # Use 'query' as the key
            if not query:
                return Response(
                    {"error": "Query parameter 'query' is required."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            print(f"Search query received: {query}")  # Debugging print statement

            # Search CustomUser across multiple fields
            users = CustomUser.objects.filter(
                Q(first_name__icontains=query) |
                Q(last_name__icontains=query) |
                Q(email__icontains=query) |
                Q(phone__icontains=query) |
                Q(username__icontains=query)
            ).distinct()  # Ensure unique results

            if not users.exists():
                return Response(
                    {"message": "No users found matching the query."},
                    status=status.HTTP_404_NOT_FOUND,
                )

            # Create a list of serialized data for both CustomUser and Profile
            result_data = []
            for user in users:
                # Get the profile related to the user
                profile = Profile.objects.filter(parent=user).first()  # Assuming 'parent' is the FK to CustomUser
                if profile:
                    # Serialize both CustomUser and Profile data
                    user_data = CustomUserProfileSerializer(user).data
                    profile_data = ProfileSerializer(profile).data
                    # Combine both user and profile data into one dictionary
                    combined_data = {**user_data, 'profile': profile_data}
                    result_data.append(combined_data)

            print(f"Serialized data: {result_data}")  # Debugging print statement
            return Response(result_data, status=status.HTTP_200_OK)

        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            return Response(
                {"detail": "Authentication failed. Please check your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # Handle validation errors
            return Response(
                {"error": e.detail},
                status=status.HTTP_400_BAD_REQUEST,
            )
        except Exception as e:
            # Handle other unexpected errors
            print(f"Unexpected error: {str(e)}")  # Debugging print statement
            return Response(
                {"error": f"An unexpected error occurred: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )




class UserActivityView(APIView):
   # permission_classes = [IsAuthenticated]
    def get(self, request, pk):
        try:
            user = CustomUser.objects.get(id=pk)        
            # Fetch related data
            publishes = Publish.objects.filter(parent=user)
            likes = LikePublish.objects.filter(user=user)
            ratings = RatePublish.objects.filter(user=user)
            investments = Invest.objects.filter(parent=user)     
            # Fetch followers and following from the user's profile
            profile = user.profile  # Assuming the user has a profile
            # Prepare data for serialization
            data = {
                'publishes': publishes,
                'likes': likes,
                'ratings': ratings,
                'investments': investments,
            }
            # Serialize the data with context and many=True
            serializer = UserActivitySerializer(
                data,
                context={'request': request, 'user': user},
                many=False  # No need for `many=True` here because the data is a dictionary
            )
            return Response(serializer.data)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
    def put(self, request, pk):
        item_type = request.data.get('type')
        item_id = request.data.get('id')
        updated_data = request.data.get('updated_data')
        if not all([item_type, item_id, updated_data]):
            return Response(
                {"error": "Missing type, id, or updated_data in the request."},
                status=400,
            )
        try:
            if item_type == 'publishes':
                item = Publish.objects.get(id=item_id)
            elif item_type == 'likes':
                item = LikePublish.objects.get(id=item_id)
            elif item_type == 'ratings':
                item = RatePublish.objects.get(id=item_id)
            elif item_type == 'investments':
                item = Invest.objects.get(id=item_id)
            else:
                return Response({"error": "Invalid type provided."}, status=400)

            # Update the fields dynamically
            for key, value in updated_data.items():
                setattr(item, key, value)
            item.save()

            return Response({"success": f"{item_type} item updated successfully."})
        except Exception as e:
            return Response({"error": str(e)}, status=404)

        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
    def delete(self, request, pk):
        """
        Handles deleting an item.
        Expected input:
        - type: Type of item ('publishes', 'likes', 'ratings', 'investments')
        - id: ID of the item to delete
        """
        item_type = request.data.get('type')
        item_id = request.data.get('id')

        if not all([item_type, item_id]):
            return Response(
                {"error": "Missing type or id in the request."},
                status=400,
            )

        try:
            if item_type == 'publishes':
                item = Publish.objects.get(id=item_id)
            elif item_type == 'likes':
                item = LikePublish.objects.get(id=item_id)
            elif item_type == 'ratings':
                item = RatePublish.objects.get(id=item_id)
            elif item_type == 'investments':
                item = Invest.objects.get(id=item_id)
            else:
                return Response({"error": "Invalid type provided."}, status=400)

            item.delete()
            return Response({"success": f"{item_type} item deleted successfully."})
        except Exception as e:
            return Response({"error": str(e)}, status=404)

        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

class ProfileDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Profile.objects.all()
    serializer_class = ProfileSerializer

    def get_object(self):
        user_id = self.kwargs.get('pk')  # Get user ID from URL
        try:
            # Debugging: print the ID
            print(f"Looking for Profile with _id: {user_id}")
            profile = Profile.objects.get(_id=user_id)
            return profile
        except Profile.DoesNotExist:
            raise NotFound(detail="User not found.")
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

from django.db.models import Count

class SuggestedUsersView(APIView):
      # Adjust permissions as needed

    def get(self, request, user_id, format=None):
        try:
            # Fetch the current user's profile
            current_user_profile = Profile.objects.get(user_id=user_id)
            current_user = current_user_profile.parent

            # Get the list of users the current user is already following
            already_following_ids = current_user_profile.following.values_list('parent__id', flat=True)

            # Find mutual connections based on the CustomUser model
            mutual_connections = CustomUser.objects.filter(
                profile__followers__parent__id__in=already_following_ids  # Users followed by those the current user follows
            ).exclude(
                id__in=already_following_ids  # Exclude already-followed users
            ).exclude(
                id=current_user.id  # Exclude the current user
            ).annotate(
                mutual_count=Count('profile__followers')  # Count mutual followers
            ).order_by('-mutual_count')  # Sort by mutual connections count

            if mutual_connections.exists():
                serializer = CustomUserProfileSerializer(mutual_connections, many=True)
                return Response(serializer.data, status=status.HTTP_200_OK)

            # If no mutual connections, find unconnected users
            unconnected_users = CustomUser.objects.exclude(
                id__in=already_following_ids  # Exclude already-followed users
            ).exclude(
                profile__followers=current_user_profile  # Exclude users following the current user
            ).exclude(
                id=current_user.id  # Exclude the current user
            )

            serializer = CustomUserProfile(unconnected_users, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except Profile.DoesNotExist:
            raise NotFound(detail="Profile not found.")
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class SuggestedUsersView(APIView):
    def get(self, request, user_id, format=None):
        try:
            current_user_profile = Profile.objects.get(user_id=user_id)
            current_user = current_user_profile.parent

            already_following_ids = current_user_profile.following.values_list('parent__id', flat=True)

            mutual_connections = CustomUser.objects.filter(
            profile__followers__parent__id__in=already_following_ids
        ).exclude(
            id__in=already_following_ids
        ).exclude(
            id=current_user.id
        ).annotate(
            mutual_count=Count('profile__followers')
        ).order_by('-mutual_count')


            if mutual_connections.exists():
                serializer = CustomUserProfileSerializer(mutual_connections, many=True)
                return Response(serializer.data, status=status.HTTP_200_OK)

            unconnected_users = CustomUser.objects.exclude(
                id__in=already_following_ids
            ).exclude(
                profile__followers=current_user_profile
            ).exclude(
                id=current_user.id
            ).prefetch_related('profile')  # Use prefetch_related for reverse relation

            serializer = UserSuggestionWithProfileSerializer(unconnected_users, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except AuthenticationFailed as auth_error:
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except Profile.DoesNotExist:
            raise NotFound(detail="Profile not found.")
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ProfileFollowersFollowingView(APIView):
    permission_classes = [AllowAny]  # You can adjust permissions as needed

    def get(self, request, user_id, format=None):
        try:
            # Fetch the profile for the given user_id
            profile = Profile.objects.get(user_id=user_id)
            
            # Get the list of followers
            followers = profile.followers.all()
            
            # Get the list of following
            following = profile.following.all()
            
            # Serialize the followers and following lists
            followers_serializer = NestedProfileSerializer(followers, many=True)
            following_serializer = NestedProfileSerializer(following, many=True)
            
            # Return the serialized data
            return Response({
                "followers": followers_serializer.data,
                "following": following_serializer.data
            }, status=status.HTTP_200_OK)

        except Profile.DoesNotExist:
            raise NotFound(detail="Profile not found.")
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


from rest_framework.parsers import MultiPartParser, FormParser
class PublishListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Publish.objects.all()
    serializer_class = PublishSerializer
    parser_classes = [MultiPartParser, FormParser]

    def create(self, request, *args, **kwargs):
        try:
            # Print the incoming data for debugging
            print("Incoming data:", request.data)

            # Use the serializer to validate and save the data
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            self.perform_create(serializer)
            # Print validated data for debugging
            print("Validated data:", serializer.validated_data)
            headers = self.get_success_headers(serializer.data)
            return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

from rest_framework.exceptions import ValidationError
'''
class PublishListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Publish.objects.all()
    serializer_class = PublishSerializer
    parser_classes = [MultiPartParser, FormParser]
    def create(self, request, *args, **kwargs):
        # Print the incoming data for debugging
        print("Incoming data:", request.data)
        # Use the serializer to validate and save the data
        serializer = self.get_serializer(data=request.data)
        try:
            # Attempt to validate the data
            serializer.is_valid(raise_exception=True)
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
        # If validation passes, save the object
        self.perform_create(serializer)
        # Print validated data for debugging
        print("Validated data:", serializer.validated_data)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
'''

class PublishListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Publish.objects.all()
    serializer_class = PublishSerializer
    parser_classes = [MultiPartParser, FormParser]
    def create(self, request, *args, **kwargs):
        try:
            # Print the incoming data for debugging
            print("Incoming data:", request.data)
            # Use the serializer to validate and save the data
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            # If validation passes, save the object
            self.perform_create(serializer)
            # Print validated data for debugging
            print("Validated data:", serializer.validated_data)
            headers = self.get_success_headers(serializer.data)
            return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

class PublishDetailView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, pk):
        try:
            # Use prefetch_related to optimize fetching related photos and videos
            publish_instance = Publish.objects.prefetch_related('photos', 'videos').get(pk=pk)
            serializer = PublishRetrieveSerializer(publish_instance, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Publish.DoesNotExist:
            return Response({"error": "Publish not found."}, status=status.HTTP_404_NOT_FOUND)

        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        try:
            # Print the incoming data
            print("Incoming data:", request.data)

            # Fetch the Publish instance to be updated
            publish_instance = Publish.objects.prefetch_related('photos', 'videos').get(pk=pk)

            # Serialize and validate the incoming data
            serializer = PublishRetrieveSerializer(
                publish_instance, 
                data=request.data, 
                context={'request': request}, 
                partial=True  # Allows partial updates
            )

            if serializer.is_valid():
                # Save the updated instance
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                # If validation fails, return the errors
                print("Validation errors:", serializer.errors)
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        except Publish.DoesNotExist:
            return Response({"error": "Publish not found."}, status=status.HTTP_404_NOT_FOUND)

        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

# View for listing and creating Photo objects related to a Publish
class PhotoListCreateView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, publish_id):
        try:
            photos = Photo.objects.filter(publish_id=publish_id)
            serializer = PhotoSerializer(photos, many=True)
            return Response(serializer.data)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
    def post(self, request, publish_id):
        try:
            data = request.data
            data['publish'] = publish_id
            serializer = PhotoSerializer(data=data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
# View for listing and creating Video objects related to a Publish
class VideoListCreateView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, publish_id):
        try:
            videos = Video.objects.filter(publish_id=publish_id)
            serializer = VideoSerializer(videos, many=True)
            return Response(serializer.data)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
    def post(self, request, publish_id):
        try:
            data = request.data
            data['publish'] = publish_id
            serializer = VideoSerializer(data=data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
from rest_framework import serializers, status
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import LikePublish, Publish, CustomUser
'''
# Serializer
class LikePublishSerializer(serializers.ModelSerializer):
    permission_classes = [IsAuthenticated]
    class Meta:
        model = LikePublish
        fields = ['_id', 'parent', 'user', 'likes', 'created_at']

'''

class LikePublishView(APIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request, id, pk):
        # Retrieve the user instance
        try:
            user = CustomUser.objects.get(id=id)
        except CustomUser.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
        
        # Retrieve the publish instance
        try:
            publish = Publish.objects.get(pk=pk)
        except Publish.DoesNotExist:
            return Response({"error": "Publish not found"}, status=status.HTTP_404_NOT_FOUND)
        try:
            # Check if the user has already liked the publish
            like, created = LikePublish.objects.get_or_create(
                user=user,
                parent=publish,
            )

            if not created:
                # If the like already exists, remove it (unlike)
                like.delete()
                message = "Like removed"
            else:
                # If the like does not exist, set likes to True and save
                like.likes = True
                like.save()
                message = "Like added"
            # Recalculate the like count after the like/unlike action
            like_count = LikePublish.objects.filter(parent=publish, likes=True).count()
            # Return the response with the updated like count
            return Response({"message": message, "like_count": like_count}, status=status.HTTP_200_OK if not created else status.HTTP_201_CREATED)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

class RatePublishView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, id, pk):
        data = request.data
        try:
            user = CustomUser.objects.get(id=id)
        except CustomUser.DoesNotExist:
            return Response({'error': "User not found"}, status=status.HTTP_404_NOT_FOUND)

        try:
            publish = Publish.objects.get(pk=pk)
        except Publish.DoesNotExist:
            return Response({"error": "Publish not found"}, status=status.HTTP_404_NOT_FOUND)

        try:
            # Check if the user has already rated the publish
            existing_rate = RatePublish.objects.filter(user=user, parent=publish).first()

            # If a rating exists, delete it to replace with the new one
            if existing_rate:
                existing_rate.delete()
                message = "Previous rating deleted and updated with new rating"
            else:
                message = "Rating successfully created"

            # Create a new rating
            RatePublish.objects.create(
                user=user,
                parent=publish,
                rate=True,
                no_of_rating=data.get('no_of_rating', 0)  # Default to 0 if no value is provided
            )

            # Calculate the total like count for the publish
            like_count = RatePublish.objects.filter(parent=publish).count()

            return Response({
                "message": message,
                "like_count": like_count  # Return the updated like count
            }, status=status.HTTP_201_CREATED)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

class LikeInvestView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, id, pk):
        # Retrieve the user instance
        try:
            user = CustomUser.objects.get(id=id)
        except CustomUser.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)        
        # Retrieve the invest instance
        try:
            invest = Invest.objects.get(pk=pk)
        except Invest.DoesNotExist:  # Correct the class reference here
            return Response({"error": "Invest not found"}, status=status.HTTP_404_NOT_FOUND)

        try:
            # Check if the user has already liked the invest
            like, created = LikeInvest.objects.get_or_create(
                user=user,
                parent=invest,
            )
            if not created:
                # If the like already exists, remove it (unlike)
                like.delete()
                message = "Like removed"
            else:
                # If the like does not exist, set likes to True and save
                like.likes = True
                like.save()
                message = "Like added"
            # Recalculate the like count after the like/unlike action
            like_count = LikeInvest.objects.filter(parent=invest, likes=True).count()
            # Return the response with the updated like count
            return Response({"message": message, "like_count": like_count}, status=status.HTTP_200_OK if not created else status.HTTP_201_CREATED)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)


from django.db.models import Sum, Q, Count, Case, When, IntegerField
'''



class PublishInvestSearchView(APIView):
    def get(self, request):
        query = request.GET.get('query', '')
        if not query:
            return Response({'error': 'Query parameter is required'}, status=status.HTTP_400_BAD_REQUEST)
        # Split the query into individual keywords
        keywords = query.split()
        # Annotate Publish objects with a match score
        publish_queryset = Publish.objects.all()
        for keyword in keywords:
            publish_queryset = publish_queryset.annotate(
                match_score=Count(
                    Case(
                        When(Q(title__icontains=keyword) | 
                             Q(author__icontains=keyword) | 
                             Q(organization__icontains=keyword) | 
                             Q(short_description__icontains=keyword), 
                             then=1),
                        output_field=IntegerField()
                    )
                )
            )
        publish_queryset = publish_queryset.order_by('-match_score')
        publish_serializer = PublishRetrieveSerializer(publish_queryset, many=True)
        # Annotate Invest objects with a match score
        invest_queryset = Invest.objects.all()
        for keyword in keywords:
            invest_queryset = invest_queryset.annotate(
                match_score=Count(
                    Case(
                        When(Q(title__icontains=keyword) |
                             Q(description__icontains=keyword) |
                             Q(category__icontains=keyword),
                             then=1),
                        output_field=IntegerField()
                    )
                )
            )
        invest_queryset = invest_queryset.order_by('-match_score')
        invest_serializer = InvestRetrieveSerializer(invest_queryset, many=True)
        return Response({
            'publish_results': publish_serializer.data,
            'invest_results': invest_serializer.data
        }, status=status.HTTP_200_OK)


'''


class PublishInvestSearchView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        try:
            query = request.GET.get('query', '')
            if not query:
                return Response({'error': 'Query parameter is required'}, status=status.HTTP_400_BAD_REQUEST)
            # Split the query into individual keywords
            keywords = query.split()
            # Build Q objects for matching multiple fields
            def build_query(keywords, fields):
                query = Q()
                for keyword in keywords:
                    for field in fields:
                        query |= Q(**{f"{field}__icontains": keyword})
                return query
            # Fields to search in Publish
            publish_fields = ['title', 'author', 'organization', 'short_description', 'target_audience']
            publish_query = build_query(keywords, publish_fields)
            # Fetch and annotate Publish results
            publish_queryset = Publish.objects.filter(publish_query).annotate(
                match_score=Sum(
                    Case(
                        *[
                            When(Q(**{f"{field}__icontains": keyword}), then=1)
                            for keyword in keywords
                            for field in publish_fields
                        ],
                        output_field=IntegerField()
                    )
                )
            ).order_by('-match_score')
            publish_serializer = PublishRetrieveSerializer(publish_queryset, many=True, context={'request': request})
            # Fields to search in Invest
            invest_fields = ['title', 'description', 'category']
            invest_query = build_query(keywords, invest_fields)
            # Fetch and annotate Invest results
            invest_queryset = Invest.objects.filter(invest_query).annotate(
                match_score=Sum(
                    Case(
                        *[
                            When(Q(**{f"{field}__icontains": keyword}), then=1)
                            for keyword in keywords
                            for field in invest_fields
                        ],
                        output_field=IntegerField()
                    )
                )
            ).order_by('-match_score')

            invest_serializer = InvestRetrieveSerializer(invest_queryset, many=True, context={'request': request})

            return Response({
                'publish_results': publish_serializer.data,
                'invest_results': invest_serializer.data
            }, status=status.HTTP_200_OK)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

class RateInvestView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, id, pk):
        try:
            data = request.data
            try:
                user = CustomUser.objects.get(id=id)
            except CustomUser.DoesNotExist:
                return Response({'error': "User not found"}, status=status.HTTP_404_NOT_FOUND)
            try:
                invest = Invest.objects.get(pk=pk)
            except invest.DoesNotExist:
                return Response({"error": "Invest not found"}, status=status.HTTP_404_NOT_FOUND)
            # Check if the user has already rated the publish
            existing_rate = RateInvest.objects.filter(user=user, parent=invest).first()
            # If a rating exists, delete it to replace with the new one
            if existing_rate:
                existing_rate.delete()
                message = "Previous rating deleted and updated with new rating"
            else:
                message = "Rating successfully created"
        # Create a new rating
            RateInvest.objects.create(
                user=user,
                parent=invest,
                rate=True,
                no_of_rating=data.get('no_of_rating', 0)  # Default to 0 if no value is provided
            )
            # Calculate the total like count for the publish
            like_count = RateInvest.objects.filter(parent=invest).count()
            return Response({
                "message": message,
                "rating_count": like_count  # Return the updated like count
            }, status=status.HTTP_201_CREATED)

        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
            
from .serializers import DeleteUserSerializer
class DeleteAccount(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request):
        try:
            # Get the logged-in user
            user = request.user
            # Use the serializer to validate the phone number from the request
            serializer = DeleteUserSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            # Check if the provided phone number matches the logged-in user's phone number
            phone = serializer.validated_data['phone']
            if user.phone != phone:
                raise ValidationError("The phone number does not match the logged-in user.")
            # Proceed with account deletion
            user.delete()
            return Response({"message": "Account deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
        except AuthenticationFailed as auth_error:
            # Handle expired or invalid token
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired. Please refresh your token."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        except ValidationError as e:
            # If validation fails, print the error details
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
'''           
# View for listing and creating Invest objects
class InvestListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Invest.objects.all()
    serializer_class = InvestSerializer
'''
class InvestListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Invest.objects.all()
    serializer_class = InvestSerializer
    def get(self, request, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")
            return super().get(request, *args, **kwargs)
        except AuthenticationFailed as auth_error:
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
        except ValidationError as e:
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

    def post(self, request, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")
            return super().post(request, *args, **kwargs)
        except AuthenticationFailed as auth_error:
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
        except ValidationError as e:
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

# View for retrieving, updating, and deleting an Invest object by ID
class InvestDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Invest.objects.all()  # Correct model: Invest
    serializer_class = InvestSerializer
    lookup_field = '_id'  # Ensure lookup by '_id'
    def get(self, request, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")
            return super().get(request, *args, **kwargs)
        except AuthenticationFailed as auth_error:
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
        except ValidationError as e:
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

    def post(self, request, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")
            return super().post(request, *args, **kwargs)
        except AuthenticationFailed as auth_error:
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
        except ValidationError as e:
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
    # View for retrieving, updating, and deleting an Invest object by ID\
    def put(self, request, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")

            # Print incoming data for debugging
            print("Incoming data:", request.data)

            partial = kwargs.pop('partial', False)  # Support partial updates
            instance = self.get_object()  # Retrieve the instance
            serializer = self.get_serializer(instance, data=request.data, partial=partial)

            if serializer.is_valid():
                serializer.save()  # Save updates
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                # Print validation errors for debugging
                print("Validation errors:", serializer.errors)
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        except AuthenticationFailed as auth_error:
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        except Invest.DoesNotExist:
            return Response({"error": "Invest not found."}, status=status.HTTP_404_NOT_FOUND)

                    

# View for listing and creating Publish objects
class SettingsListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Settings.objects.all()
    serializer_class = SettingsSerializer
    def get(self, request, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")
            return super().get(request, *args, **kwargs)
        except AuthenticationFailed as auth_error:
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
        except ValidationError as e:
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

    def post(self, request, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")
            return super().post(request, *args, **kwargs)
        except AuthenticationFailed as auth_error:
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
        except ValidationError as e:
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
# View for retrieving, updating, and deleting an Invest object by ID

# View for retrieving, updating, and deleting a Publish object
class SettingsDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Settings.objects.all()
    serializer_class = SettingsSerializer
    def get(self, request, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")
            return super().get(request, *args, **kwargs)
        except AuthenticationFailed as auth_error:
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
        except ValidationError as e:
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

    def post(self, request, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")
            return super().post(request, *args, **kwargs)
        except AuthenticationFailed as auth_error:
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
        except ValidationError as e:
            print("Validation error:", e.detail)
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)

'''

class UserFeedView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]  # Change as needed
    def get(self, request, user_id, *args, **kwargs):
        user = get_object_or_404(CustomUser, id=user_id)
        profile = get_object_or_404(Profile, parent=user)

        if profile.make_profile_public:
            # If the profile is public, display all Publish and Invest content
            publishes = Publish.objects.all()
            invests = Invest.objects.all()
        else:
            # If the profile is not public, show only content visible to followers
            follower_ids = profile.followers.values_list('parent__id', flat=True)
            publishes = Publish.objects.filter(parent__id__in=follower_ids)
            invests = Invest.objects.filter(parent__id__in=follower_ids)
        data = {
            'publish': PublishRetrieveSerializer(publishes, many=True, context={'request': request}).data,
            'invest': InvestRetrieveSerializer(invests, many=True, context={'request': request}).data,
        }
        return Response(data)

    def put(self, request, user_id, *args, **kwargs):
        user = get_object_or_404(CustomUser, id=user_id)
        publish_id = request.data.get('publish_id')
        invest_id = request.data.get('invest_id')

        # Update Publish
        if publish_id:
            publish = get_object_or_404(Publish, id=publish_id, parent=user)
            publish_serializer = PublishSerializer(publish, data=request.data, partial=True)
            if publish_serializer.is_valid():
                publish_serializer.save()
                return Response(publish_serializer.data, status=status.HTTP_200_OK)
            return Response(publish_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        # Update Invest
        if invest_id:
            invest = get_object_or_404(Invest, id=invest_id, parent=user)
            invest_serializer = InvestSerializer(invest, data=request.data, partial=True)
            if invest_serializer.is_valid():
                invest_serializer.save()
                return Response(invest_serializer.data, status=status.HTTP_200_OK)
            return Response(invest_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        return Response({"detail": "Invalid request"}, status=status.HTTP_400_BAD_REQUEST)
    def delete(self, request, user_id, *args, **kwargs):
        user = get_object_or_404(CustomUser, id=user_id)
        publish_id = request.data.get('publish_id')
        invest_id = request.data.get('invest_id')
        # Delete Publish
        if publish_id:
            publish = get_object_or_404(Publish, id=publish_id, parent=user)
            publish.delete()
            return Response({"detail": "Publish deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
        # Delete Invest
        if invest_id:
            invest = get_object_or_404(Invest, id=invest_id, parent=user)
            invest.delete()
            return Response({"detail": "Invest deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
        return Response({"detail": "Invalid request"}, status=status.HTTP_400_BAD_REQUEST)

'''

class UserFeedView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]  # Ensure authenticated users only

    def get(self, request, user_id, *args, **kwargs):
        try:
            # Ensure the user is authenticated
            if not request.user.is_authenticated:
                raise AuthenticationFailed("Authentication required.")
            
            # Retrieve user and profile
            user = get_object_or_404(CustomUser, id=user_id)
            profile = get_object_or_404(Profile, parent=user)

            if profile.make_profile_public:
                # If the profile is public, display all Publish and Invest content
                publishes = Publish.objects.all()
                invests = Invest.objects.all()
            else:
                # If the profile is not public, show only content visible to followers
                follower_ids = profile.followers.values_list('parent__id', flat=True)
                publishes = Publish.objects.filter(parent__id__in=follower_ids)
                invests = Invest.objects.filter(parent__id__in=follower_ids)
            
            # Serialize and return the data
            data = {
                'publish': PublishRetrieveSerializer(publishes, many=True, context={'request': request}).data,
                'invest': InvestRetrieveSerializer(invests, many=True, context={'request': request}).data,
            }
            return Response(data)

        except AuthenticationFailed as auth_error:
            # Handle authentication errors
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
    def put(self, request, user_id, *args, **kwargs):
        try:
            user = get_object_or_404(CustomUser, id=user_id)
            publish_id = request.data.get('publish_id')
            invest_id = request.data.get('invest_id')
            # Update Publish
            if publish_id:
                publish = get_object_or_404(Publish, id=publish_id, parent=user)
                publish_serializer = PublishSerializer(publish, data=request.data, partial=True)
                if publish_serializer.is_valid():
                    publish_serializer.save()
                    return Response(publish_serializer.data, status=status.HTTP_200_OK)
                return Response(publish_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            # Update Invest
            if invest_id:
                invest = get_object_or_404(Invest, id=invest_id, parent=user)
                invest_serializer = InvestSerializer(invest, data=request.data, partial=True)
                if invest_serializer.is_valid():
                    invest_serializer.save()
                    return Response(invest_serializer.data, status=status.HTTP_200_OK)
                return Response(invest_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            return Response({"detail": "Invalid request"}, status=status.HTTP_400_BAD_REQUEST)
        except AuthenticationFailed as auth_error:
            # Handle authentication errors
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
    def delete(self, request, user_id, *args, **kwargs):
        try:
            user = get_object_or_404(CustomUser, id=user_id)
            publish_id = request.data.get('publish_id')
            invest_id = request.data.get('invest_id')
            # Delete Publish
            if publish_id:
                publish = get_object_or_404(Publish, id=publish_id, parent=user)
                publish.delete()
                return Response({"detail": "Publish deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
            # Delete Invest
            if invest_id:
                invest = get_object_or_404(Invest, id=invest_id, parent=user)
                invest.delete()
                return Response({"detail": "Invest deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
            return Response({"detail": "Invalid request"}, status=status.HTTP_400_BAD_REQUEST)

        except AuthenticationFailed as auth_error:
            # Handle authentication errors
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )

class EnableNotificationsView(APIView):
    permission_classes = [IsAuthenticated]
    def put(self, pk):
        try:
            settings = Profile.objects.get(_id=pk)
            settings.enable_notifications=True
            settings.save()
            return Response({'enable_notifications': settings.enable_notifications}, status=status.HTTP_200_OK)
        except AuthenticationFailed as auth_error:
            # Handle authentication errors
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )
class EnableDarkModeView(APIView):
    permission_classes = [IsAuthenticated]
    def patch(self, request):
        try:
            settings = Settings.objects.get(parent=request.user)
            settings.enable_dark_mode = request.data.get('enable_dark_mode', settings.enable_dark_mode)
            settings.save()
            return Response({'enable_dark_mode': settings.enable_dark_mode}, status=status.HTTP_200_OK)
        except AuthenticationFailed as auth_error:
            # Handle authentication errors
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )

class EnableNotificationsView(APIView):
    permission_classes = [IsAuthenticated]
    def put(self, request, pk, *args, **kwargs):
        try:
            # Retrieve the profile object
            settings = Profile.objects.get(_id=pk)            
            # Update the enable_notifications field
            settings.enable_notifications = True
            settings.save()
            # Return a success response
            return Response({'enable_notifications': settings.enable_notifications}, status=status.HTTP_200_OK)
        except Profile.DoesNotExist:
            # Handle the case where the Profile does not exist
            return Response({'error': 'Profile not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            # Handle any other exceptions
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        except AuthenticationFailed as auth_error:
            # Handle authentication errors
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )

class MakeProfilePublicView(APIView):
    permission_classes = [AllowAny]
    def put(self, request, pk, *args, **kwargs):
        try:
            # Retrieve the profile object
            settings = Profile.objects.get(_id=pk)
            # Update the enable_notifications field
            settings.make_profile_public = True
            settings.save()
            # Return a success response
            return Response({'make_profile_public': settings.enable_notifications}, status=status.HTTP_200_OK)
        except Profile.DoesNotExist:
            # Handle the case where the Profile does not exist
            return Response({'error': 'Profile not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            # Handle any other exceptions
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        except AuthenticationFailed as auth_error:
            # Handle authentication errors
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )


class ShowOnlineStatusView(APIView):
    permission_classes = [IsAuthenticated]
    def put(self, request, pk, *args, **kwargs):
        try:
            # Retrieve the profile object
            settings = Profile.objects.get(_id=pk)
            # Update the enable_notifications field
            settings.show_online_status = True
            settings.save()
            # Return a success response
            return Response({'show_online_status': settings.enable_notifications}, status=status.HTTP_200_OK)
        except Profile.DoesNotExist:
            # Handle the case where the Profile does not exist
            return Response({'error': 'Profile not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            # Handle any other exceptions
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        except AuthenticationFailed as auth_error:
            # Handle authentication errors
            print("Authentication error:", auth_error)
            return Response(
                {"detail": "Token expired or invalid. Please log in again."},
                status=status.HTTP_401_UNAUTHORIZED
            )

class EnableTwoFactorAuthenticationView(APIView):
    permission_classes = [IsAuthenticated]
    def put(self, request, pk, *args, **kwargs):
        try:
            # Retrieve the profile object
            settings = CustomUser.objects.get(id=pk)
            # Update the enable_notifications field
            settings.two_factor_authentication = True
            settings.save()
            # Return a success response
            return Response({'two_factor_authentication': settings.two_factor_authentication}, status=status.HTTP_200_OK)
        except Profile.DoesNotExist:
            # Handle the case where the Profile does not exist
            return Response({'error': 'Profile not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            # Handle any other exceptions
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        except AuthenticationFailed as auth_error:
                    # Handle authentication errors
                    print("Authentication error:", auth_error)
                    return Response(
                        {"detail": "Token expired or invalid. Please log in again."},
                        status=status.HTTP_401_UNAUTHORIZED
                    )        