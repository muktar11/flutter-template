# Generated by Django 5.0.4 on 2024-11-20 08:47

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Account', '0010_remove_message_channel_remove_message_sender_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='profile',
            name='username',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]
