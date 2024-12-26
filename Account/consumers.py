import django
django.setup()
'''
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatChannel, ChatMessage, CustomUser
from asgiref.sync import sync_to_async
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from urllib.parse import parse_qs
# Import the necessary function at the top of your consumers.py file
from channels.db import database_sync_to_async
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from urllib.parse import parse_qs

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Get user ID from the query parameters
        query_string = self.scope['query_string'].decode('utf-8')
        query_params = parse_qs(query_string)
        self.user_id = query_params.get('sid', [None])[0]  # Extract the user_id from query parameters

        if not self.user_id:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'User ID is required to connect.'
            }))
            return

        # Accept the WebSocket connection
        await self.accept()

        self.channel_name = None
        self.channel_group_name = None

        # Send a message back to the client with the user ID
        await self.send(text_data=json.dumps({
            'type': 'connection_status',
            'message': f'User ID {self.user_id} connected. Waiting for the second user...'
        }))


    async def receive(self, text_data):
        data = json.loads(text_data)
        action = data.get('action')

        if action == 'create_channel':
            receiver_id = data.get('rid')

            # Ensure the user is not trying to chat with themselves
            if self.user_id == receiver_id:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'You cannot chat with yourself.'
                }))
                return

            # Get the CustomUser instances
            user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
            user2 = await sync_to_async(CustomUser.objects.get)(id=receiver_id)

            # Check if a channel already exists between the two users
            def get_existing_channel(user1, user2):
                # Ensure only one channel exists between the users
                channels = ChatChannel.objects.filter(participants__in=[user1, user2]).distinct()
                if channels.count() > 1:
                    # Handle the case where multiple channels exist (perhaps merge them or raise an error)
                    raise ValueError("Multiple channels found between these users.")
                return channels.first()  # Return the first channel if it exists

            # Get the existing channel or create a new one
            try:
                channel = await database_sync_to_async(get_existing_channel)(user1, user2)
            except ValueError as e:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': str(e)
                }))
                return

            if not channel:
                # If no existing channel, create a new channel
                channel = await database_sync_to_async(ChatChannel.create_channel)(user1, user2)

            # Set the channel group name
            self.channel_name = channel.name
            self.channel_group_name = f'chat_{self.channel_name}'

            # Join the group
            await self.channel_layer.group_add(
                self.channel_group_name,
                self.channel_name
            )

            # Get the last message if any
            def get_last_message(channel):
                return ChatMessage.objects.filter(channel=channel).order_by('-timestamp').first()

            last_message = await database_sync_to_async(get_last_message)(channel)

            if last_message:
                # If there is a last message, send it
                await self.send(text_data=json.dumps({
                    'type': 'channel_info',
                    'channel_name': self.channel_name,
                    'messages': [{'sender': last_message.sender.username, 'content': last_message.content}]
                }))
            else:
                # If no previous messages, send an empty list
                await self.send(text_data=json.dumps({
                    'type': 'channel_info',
                    'channel_name': self.channel_name,
                    'messages': []
                }))
        if action == 'send_message':
            content = data.get('content')

            # Ensure content is not empty
            if content:
                # Get the user and channel asynchronously
                user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
                channel = await sync_to_async(ChatChannel.objects.get)(name=self.channel_name)

                # Get the other participant asynchronously
                recipient = await sync_to_async(channel.participants.exclude(id=user1.id).first)()

                # Create the chat message
                message = ChatMessage(
                    channel=channel,
                    sender=user1,
                    recipient=recipient,  # Get the other participant
                    content=content
                )

                # Save the message asynchronously
                await sync_to_async(message.save)()

                # Send the message to the WebSocket group
                await self.channel_layer.group_send(
                    self.channel_group_name,
                    {
                        'type': 'chat_message',
                        'sender': user1.username,
                        'content': content,
                        'timestamp': message.timestamp.isoformat()  # Format timestamp as ISO 8601 string
                    }
                )
'''

'''
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatChannel, ChatMessage, CustomUser
from asgiref.sync import sync_to_async
from urllib.parse import parse_qs
from channels.db import database_sync_to_async

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        query_string = self.scope['query_string'].decode('utf-8')
        query_params = parse_qs(query_string)
        self.user_id = query_params.get('sid', [None])[0]

        if not self.user_id:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'User ID is required to connect.'
            }))
            return

        await self.accept()

        self.channel_name = None
        self.channel_group_name = None

        await self.send(text_data=json.dumps({
            'type': 'connection_status',
            'message': f'User ID {self.user_id} connected. Waiting for the second user...'
        }))

    async def receive(self, text_data):
        data = json.loads(text_data)
        action = data.get('action')

        if action == 'create_channel':
            receiver_id = data.get('rid')

            if self.user_id == receiver_id:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'You cannot chat with yourself.'
                }))
                return

            user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
            user2 = await sync_to_async(CustomUser.objects.get)(id=receiver_id)

            def get_existing_channel(user1, user2):
                channels = ChatChannel.objects.filter(participants__in=[user1, user2]).distinct()
                if channels.count() > 1:
                    raise ValueError("Multiple channels found between these users.")
                return channels.first()

            try:
                channel = await database_sync_to_async(get_existing_channel)(user1, user2)
            except ValueError as e:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': str(e)
                }))
                return

            if not channel:
                channel = await database_sync_to_async(ChatChannel.create_channel)(user1, user2)

            self.channel_name = channel.name
            self.channel_group_name = f'chat_{self.channel_name}'

            await self.channel_layer.group_add(
                self.channel_group_name,
                self.channel_name
            )

            def get_last_message(channel):
                return ChatMessage.objects.filter(channel=channel).order_by('-timestamp').first()

            last_message = await database_sync_to_async(get_last_message)(channel)

            if last_message:
                await self.send(text_data=json.dumps({
                    'type': 'channel_info',
                    'channel_name': self.channel_name,
                    'messages': [{'sender': last_message.sender.username, 'content': last_message.content}]
                }))
            else:
                await self.send(text_data=json.dumps({
                    'type': 'channel_info',
                    'channel_name': self.channel_name,
                    'messages': []
                }))

        if action == 'send_message':
            content = data.get('content')

            # Ensure content is not empty
            if content:
                # Get the user and channel asynchronously
                user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
                channel = await sync_to_async(ChatChannel.objects.get)(name=self.channel_name)

                # Get the other participant asynchronously
                recipient = await sync_to_async(channel.participants.exclude(id=user1.id).first)()

                # Create the chat message
                message = ChatMessage(
                    channel=channel,
                    sender=user1,
                    recipient=recipient,  # Get the other participant
                    content=content
                )

                # Save the message asynchronously
                await sync_to_async(message.save)()

                # Send the message to the WebSocket group
                await self.channel_layer.group_send(
                    self.channel_group_name,
                    {
                        'type': 'chat_message',
                        'sender': user1.username,
                        'content': content,
                        'timestamp': message.timestamp.isoformat()  # Format timestamp as ISO 8601 string
                    }
                )

'''
'''


import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatChannel, ChatMessage, CustomUser
from asgiref.sync import sync_to_async
from urllib.parse import parse_qs
from channels.db import database_sync_to_async

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        query_string = self.scope['query_string'].decode('utf-8')
        query_params = parse_qs(query_string)
        self.user_id = query_params.get('sid', [None])[0]

        if not self.user_id:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'User ID is required to connect.'
            }))
            return

        await self.accept()

        self.channel_name = None
        self.channel_group_name = None

        await self.send(text_data=json.dumps({
            'type': 'connection_status',
            'message': f'User ID {self.user_id} connected. Waiting for the second user...'
        }))

    async def receive(self, text_data):
        data = json.loads(text_data)
        action = data.get('action')

        if action == 'create_channel':
            receiver_id = data.get('rid')

            if self.user_id == receiver_id:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'You cannot chat with yourself.'
                }))
                return

            user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
            user2 = await sync_to_async(CustomUser.objects.get)(id=receiver_id)

            def get_existing_channel(user1, user2):
                channels = ChatChannel.objects.filter(participants__in=[user1, user2]).distinct()
                if channels.count() > 1:
                    raise ValueError("Multiple channels found between these users.")
                return channels.first()

            try:
                channel = await database_sync_to_async(get_existing_channel)(user1, user2)
            except ValueError as e:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': str(e)
                }))
                return

            if not channel:
                channel = await database_sync_to_async(ChatChannel.create_channel)(user1, user2)

            self.channel_name = channel.name
            self.channel_group_name = f'chat_{self.channel_name}'

            await self.channel_layer.group_add(
                self.channel_group_name,
                self.channel_name  # Ensure correct usage of channel_group_name
            )

            def get_last_message(channel):
                return ChatMessage.objects.filter(channel=channel).order_by('-timestamp').first()

            last_message = await database_sync_to_async(get_last_message)(channel)

            if last_message:
                await self.send(text_data=json.dumps({
                    'type': 'channel_info',
                    'channel_name': self.channel_name,
                    'messages': [{'sender': last_message.sender.username, 'content': last_message.content}]
                }))
            else:
                await self.send(text_data=json.dumps({
                    'type': 'channel_info',
                    'channel_name': self.channel_name,
                    'messages': []
                }))

        if action == 'send_message':
            content = data.get('content')

            # Ensure content is not empty
            if content:
                # Get the user and channel asynchronously
                user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
                channel = await sync_to_async(ChatChannel.objects.get)(name=self.channel_name)

                # Get the other participant asynchronously
                recipient = await sync_to_async(channel.participants.exclude(id=user1.id).first)()  # Fixed issue

                # Create the chat message
                message = ChatMessage(
                    channel=channel,
                    sender=user1,
                    recipient=recipient,  # Get the other participant
                    content=content
                )

                # Save the message asynchronously
                await sync_to_async(message.save)()

                # Send the message to the WebSocket group
                await self.channel_layer.group_send(
                    self.channel_group_name,
                    {
                        'type': 'chat_message',
                        'sender': user1.username,
                        'content': content,
                        'timestamp': message.timestamp.isoformat()  # Format timestamp as ISO 8601 string
                    }
                )

    async def disconnect(self, close_code):
        # Handle WebSocket disconnects
        if self.channel_group_name:
            await self.channel_layer.group_discard(self.channel_group_name, self.channel_name)
'''


'''
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatChannel, ChatMessage, CustomUser
from asgiref.sync import sync_to_async
from urllib.parse import parse_qs
from channels.db import database_sync_to_async




@database_sync_to_async
def fetch_messages(channel):
    return list(ChatMessage.objects.filter(channel=channel))


class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        query_string = self.scope['query_string'].decode('utf-8')
        query_params = parse_qs(query_string)
        self.user_id = query_params.get('sid', [None])[0]

        if not self.user_id:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'User ID is required to connect.'
            }))
            return

        await self.accept()

        self.channel_name = None
        self.channel_group_name = None

        await self.send(text_data=json.dumps({
            'type': 'connection_status',
            'message': f'User ID {self.user_id} connected. Waiting for the second user...'
        }))


    async def receive(self, text_data):
        data = json.loads(text_data)
        action = data.get('action')

        if action == 'create_channel':
            receiver_id = data.get('rid')

            if self.user_id == receiver_id:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'You cannot chat with yourself.'
                }))
                return

            user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
            user2 = await sync_to_async(CustomUser.objects.get)(id=receiver_id)

            def get_existing_channel(user1, user2):
                channels = ChatChannel.objects.filter(participants__in=[user1, user2]).distinct()
                if channels.count() > 1:
                    raise ValueError("Multiple channels found between these users.")
                return channels.first()

            try:
                channel = await database_sync_to_async(get_existing_channel)(user1, user2)
            except ValueError as e:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': str(e)
                }))
                return

            if not channel:
                channel = await database_sync_to_async(ChatChannel.create_channel)(user1, user2)

            # Set self.channel
            self.channel = channel
            self.channel_name = channel.name
            self.channel_group_name = f'chat_{self.channel_name}'

            await self.channel_layer.group_add(
                self.channel_group_name,
                self.channel_name
            )

            @database_sync_to_async
            def get_message_data(messages):
                return [{'sender': message.sender.username, 'content': message.content, 'timestamp': message.timestamp.isoformat()} for message in messages]

            messages = await fetch_messages(self.channel)
            message_data = await get_message_data(messages)

            # Fetch messages asynchronously
          #  messages = await fetch_messages(self.channel)

            # Prepare message data to send back
#            message_data = [{'sender': message.sender.username, 'content': message.content, 'timestamp': message.timestamp.isoformat()} for message in messages]

            await self.send(text_data=json.dumps({
                'type': 'channel_info',
                'channel_name': self.channel_name,
                'messages': message_data
            }))

        elif action == 'send_message':
            content = data.get('content')
            channel_name = data.get('channel_name')

            if not channel_name:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Channel name is required to send a message.'
                }))
                return

            if not content:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Message content cannot be empty.'
                }))
                return

            # Find the channel by name
            @database_sync_to_async
            def get_channel_by_name(name):
                try:
                    return ChatChannel.objects.get(name=name)
                except ChatChannel.DoesNotExist:
                    return None

            channel = await get_channel_by_name(channel_name)

            if not channel:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': f'No channel found with the name "{channel_name}".'
                }))
                return

            # Get the sender user
            user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)

            # Get the other participant in the channel
            @database_sync_to_async
            def get_recipient(channel, user):
                return channel.participants.exclude(id=user.id).first()

            recipient = await get_recipient(channel, user1)

            if not recipient:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Recipient not found in the channel.'
                }))
                return

            # Create and save the chat message
            @database_sync_to_async
            def save_message(channel, sender, recipient, content):
                message = ChatMessage(
                    channel=channel,
                    sender=sender,
                    recipient=recipient,
                    content=content
                )
                message.save()
                return message

            message = await save_message(channel, user1, recipient, content)

            # Send the message to the WebSocket group
            await self.channel_layer.group_send(
                f'chat_{channel.name}',
                {
                    'type': 'chat_message',
                    'sender': user1.username,
                    'content': content,
                    'timestamp': message.timestamp.isoformat()
                }
            )

            # Acknowledge the message was sent
            await self.send(text_data=json.dumps({
                'type': 'message_sent',
                'channel_name': channel.name,
                'content': content,
                'timestamp': message.timestamp.isoformat()
            }))

'''


'''

import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatChannel, ChatMessage, CustomUser
from asgiref.sync import sync_to_async
from urllib.parse import parse_qs
from channels.db import database_sync_to_async




@database_sync_to_async
def fetch_messages(channel):
    return list(ChatMessage.objects.filter(channel=channel))


class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        query_string = self.scope['query_string'].decode('utf-8')
        query_params = parse_qs(query_string)
        self.user_id = query_params.get('sid', [None])[0]

        if not self.user_id:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'User ID is required to connect.'
            }))
            return

        await self.accept()

        self.channel_name = None
        self.channel_group_name = None

        await self.send(text_data=json.dumps({
            'type': 'connection_status',
            'message': f'User ID {self.user_id} connected. Waiting for the second user...'
        }))


    async def receive(self, text_data):
        data = json.loads(text_data)
        action = data.get('action')

        if action == 'create_channel':
            receiver_id = data.get('rid')
            print('receiver_id', receiver_id)
            if self.user_id == receiver_id:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'You cannot chat with yourself.'
                }))
                return

            user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
            user2 = await sync_to_async(CustomUser.objects.get)(id=receiver_id)

            def get_existing_channel(user1, user2):
                channels = ChatChannel.objects.filter(participants__in=[user1, user2]).distinct()
                if channels.count() > 1:
                    raise ValueError("Multiple channels found between these users.")
                return channels.first()

            try:
                channel = await database_sync_to_async(get_existing_channel)(user1, user2)
            except ValueError as e:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': str(e)
                }))
                return

            if not channel:
                channel = await database_sync_to_async(ChatChannel.create_channel)(user1, user2)

            # Set self.channel
            self.channel = channel
            self.channel_name = channel.name
            self.channel_group_name = f'chat_{self.channel_name}'

            await self.channel_layer.group_add(
                self.channel_group_name,
                self.channel_name
            )

            @database_sync_to_async
            def get_message_data(messages):
                return [{'sender': message.sender.username, 'content': message.content, 'timestamp': message.timestamp.isoformat()} for message in messages]

            messages = await fetch_messages(self.channel)
            message_data = await get_message_data(messages)

            # Fetch messages asynchronously
          #  messages = await fetch_messages(self.channel)

            # Prepare message data to send back
#            message_data = [{'sender': message.sender.username, 'content': message.content, 'timestamp': message.timestamp.isoformat()} for message in messages]

            await self.send(text_data=json.dumps({
                'type': 'channel_info',
                'channel_name': self.channel_name,
                'messages': message_data
            }))

        elif action == 'send_message':
            content = data.get('content')
            channel_name = data.get('channel_name')

            if not channel_name:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Channel name is required to send a message.'
                }))
                return

            if not content:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Message content cannot be empty.'
                }))
                return

            # Find the channel by name
            @database_sync_to_async
            def get_channel_by_name(name):
                try:
                    return ChatChannel.objects.get(name=name)
                except ChatChannel.DoesNotExist:
                    return None

            channel = await get_channel_by_name(channel_name)

            if not channel:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': f'No channel found with the name "{channel_name}".'
                }))
                return

            # Get the sender user
            user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)

            # Get the other participant in the channel
            @database_sync_to_async
            def get_recipient(channel, user):
                return channel.participants.exclude(id=user.id).first()

            recipient = await get_recipient(channel, user1)

            if not recipient:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Recipient not found in the channel.'
                }))
                return

            # Create and save the chat message
            @database_sync_to_async
            def save_message(channel, sender, recipient, content):
                message = ChatMessage(
                    channel=channel,
                    sender=sender,
                    recipient=recipient,
                    content=content
                )
                message.save()
                return message

            message = await save_message(channel, user1, recipient, content)

            # Send the message to the WebSocket group
            await self.channel_layer.group_send(
                f'chat_{channel.name}',
                {
                    'type': 'chat_message',
                    'sender': user1.username,
                    'content': content,
                    'timestamp': message.timestamp.isoformat()
                }
            )

            # Acknowledge the message was sent
            await self.send(text_data=json.dumps({
                'type': 'message_sent',
                'channel_name': channel.name,
                'content': content,
                'timestamp': message.timestamp.isoformat()
            }))

'''

import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatChannel, ChatMessage, CustomUser
from asgiref.sync import sync_to_async
from urllib.parse import parse_qs
from channels.db import database_sync_to_async
from django.db.models import Q



@database_sync_to_async
def fetch_messages(channel):
    return list(ChatMessage.objects.filter(channel=channel))


class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        query_string = self.scope['query_string'].decode('utf-8')
        query_params = parse_qs(query_string)
        self.user_id = query_params.get('sid', [None])[0]

        if not self.user_id:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'User ID is required to connect.'
            }))
            return

        await self.accept()

        self.channel_name = None
        self.channel_group_name = None

        await self.send(text_data=json.dumps({
            'type': 'connection_status',
            'message': f'User ID {self.user_id} connected. Waiting for the second user...'
        }))


    async def receive(self, text_data):
        data = json.loads(text_data)
        action = data.get('action')

        if action == 'create_channel':
            receiver_id = data.get('rid')
            print('receiver_id', receiver_id)
            if self.user_id == receiver_id:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'You cannot chat with yourself.'
                }))
                return

            user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
            user2 = await sync_to_async(CustomUser.objects.get)(id=receiver_id)

            def get_existing_channel(user1, user2):
                #channels = ChatChannel.objects.filter(participants__in=[user1, user2]).distinct()
                channels = ChatChannel.objects.filter(Q(participants=user1) & Q(participants=user2))
                if channels.count() > 1:
                    raise ValueError("Multiple channels found between these users.")
                return channels.first()

            try:
                channel = await database_sync_to_async(get_existing_channel)(user1, user2)
            except ValueError as e:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': str(e)
                }))
                return

            if not channel:
                channel = await database_sync_to_async(ChatChannel.create_channel)(user1, user2)

            # Set self.channel
            self.channel = channel
            self.channel_name = channel.name
            self.channel_group_name = f'chat_{self.channel_name}'

            await self.channel_layer.group_add(
                self.channel_group_name,
                self.channel_name
            )

            @database_sync_to_async
            def get_message_data(messages):
                return [{'sender': message.sender.username, 
                        'sender_id': message.sender.id, 
                        'recipient': message.recipient.username,
                        'recipient_id': message.recipient.id,
                        'content': message.content, 
                        'timestamp': message.timestamp.isoformat()} for message in messages]

            messages = await fetch_messages(self.channel)
            message_data = await get_message_data(messages)

            # Fetch messages asynchronously
          #  messages = await fetch_messages(self.channel)

            # Prepare message data to send back
#            message_data = [{'sender': message.sender.username, 'content': message.content, 'timestamp': message.timestamp.isoformat()} for message in messages]

            await self.send(text_data=json.dumps({
                'type': 'channel_info',
                'channel_name': self.channel_name,
                'messages': message_data
            }))

        elif action == 'send_message':
            content = data.get('content')
            channel_name = data.get('channel_name')
            recepient = data.get('rid')

            if not channel_name:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Channel name is required to send a message.'
                }))
                return

            if not content:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Message content cannot be empty.'
                }))
                return

            # Find the channel by name
            @database_sync_to_async
            def get_channel_by_name(name):
                try:
                    return ChatChannel.objects.get(name=name)
                except ChatChannel.DoesNotExist:
                    return None

            channel = await get_channel_by_name(channel_name)

            if not channel:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': f'No channel found with the name "{channel_name}".'
                }))
                return

            # Get the sender user
            # Get the sender user
            try:
                user1 = await sync_to_async(CustomUser.objects.get)(id=self.user_id)
            except CustomUser.DoesNotExist:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': f'Sender user with ID {self.user_id} does not exist.'
                }))
                return

            # Get the recipient user
            recepient = data.get('rid')
            if not recepient:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Recipient ID (rid) is required.'
                }))
                return

            try:
                user2 = await sync_to_async(CustomUser.objects.get)(id=recepient)
            except CustomUser.DoesNotExist:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': f'Recipient user with ID {recepient} does not exist.'
                }))
                return


            # Get the other participant in the channel
            @database_sync_to_async
            def get_recipient(channel, user):
                return channel.participants.exclude(id=user.id).first()

            recipient = await get_recipient(channel, user1)

            if not recipient:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Recipient not found in the channel.'
                }))
                return

            # Create and save the chat message
            @database_sync_to_async
            def save_message(channel, sender, recipient, content):
                message = ChatMessage(
                    channel=channel,
                    sender=sender,
                    recipient=recipient,
                    content=content
                )
                message.save()
                return message

            message = await save_message(channel, user1, recipient, content)

            # Send the message to the WebSocket group
            await self.channel_layer.group_send(
                f'chat_{channel.name}',
                {
                    'type': 'chat_message',
                    'sender': user1.username,
                    'sender_id':user1.id,
                    'recipient': user2.username,
                    'recipient_id':user2.id,
                    'content': content,
                    'timestamp': message.timestamp.isoformat()
                }
            )

            # Acknowledge the message was sent
            await self.send(text_data=json.dumps({
                'type': 'message_sent',
                'channel_name': channel.name,
                'content': content,
                'timestamp': message.timestamp.isoformat()
            }))
