# Generated by Django 5.0.4 on 2024-12-07 19:49

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Account', '0021_likeinvest_rateinvest'),
    ]

    operations = [
        migrations.AddField(
            model_name='invest',
            name='created_at',
            field=models.DateTimeField(auto_now=True),
        ),
    ]
