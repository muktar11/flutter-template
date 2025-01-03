# Generated by Django 5.0.4 on 2024-12-04 15:03

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Account', '0016_profile_enable_notifications_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='profile',
            name='enable_notifications',
            field=models.BooleanField(default=True),
        ),
        migrations.AlterField(
            model_name='profile',
            name='make_profile_public',
            field=models.BooleanField(default=True),
        ),
        migrations.AlterField(
            model_name='profile',
            name='show_online_status',
            field=models.BooleanField(default=True),
        ),
        migrations.AlterField(
            model_name='profile',
            name='two_factor_authentication',
            field=models.BooleanField(default=True),
        ),
    ]
