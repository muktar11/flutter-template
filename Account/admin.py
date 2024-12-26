from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser
from .forms import CustomUserCreationForm, CustomUserChangeForm
from django.contrib import admin
from .models import (
Publish, Photo, Profile,
Video, LikePublish,Invest,
RatePublish, ChatChannel,
ChatMessage, LikeInvest, RateInvest 
) 

class CustomUserAdmin(UserAdmin):
    form = CustomUserChangeForm
    add_form = CustomUserCreationForm
    model = CustomUser
    list_display = ('username', 'phone', 'first_name', 'last_name', 'two_factor_authentication', 'two_factor_auth_code', ' two_factor_auth_code_expiration', 'is_staff')
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('phone',)}),
    )

class PhotoInline(admin.TabularInline):
    model = Photo
    extra = 1

class VideoInline(admin.TabularInline):
    model = Video
    extra = 1

class PublishAdmin(admin.ModelAdmin):
    inlines = [PhotoInline, VideoInline]

admin.site.register(CustomUser)
admin.site.register(Publish, PublishAdmin)
admin.site.register(Invest)
admin.site.register(Profile)
admin.site.register(Photo)
admin.site.register(Video)
admin.site.register(LikePublish)
admin.site.register(RatePublish)
admin.site.register(ChatChannel)
admin.site.register(ChatMessage)
admin.site.register(LikeInvest)
admin.site.register(RateInvest)