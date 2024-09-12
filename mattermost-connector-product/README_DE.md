# Mattermost Konnektor

Der Mattermost-Konnektor von Axon Ivy integriert Mattermost-Funktionen in deine Axon Ivy Prozessanwendung.

Dieser Konnektor:

- unterstützt dich mit einer Demo-Implementierung, um den Integrationsaufwand zu reduzieren.
- gewährleistet vollen Zugriff auf die APIs von [Mattermost](https://api.mattermost.com/).
- ermöglicht es dir, den Axon Ivy-Prozess durch Eingabe des Slash-Kommandos im Mattermost-Kanal zu starten.
- ermöglicht das Senden von Nachrichten an den Mattermost-Kanal aus der Axon Ivy-Oberfläche.
- benachrichtigt Benutzer im Kanal über neue Axon Ivy-Workflow-Aufgaben.

## Demo

1. Hit the slash command key on the channel's chat.
The Axon Ivy process will be triggered and create a new task.
The task's information will be sent to the channel by a message.

![call-slash-command](images/slash-command.png)

2. Click on the link, start and finish task.
The data from this task will be sent back to the channel.

![task-notification-from-ivy](images/task-notification-from-ivy.png)

### Setup

Mattermost Instance

1. Ref to [Deploy Mattermost](https://docs.mattermost.com/guides/deployment.html).
2. Create Team, User, ...
3. Go to the System Console to enable Personal Access Tokens
![enable-personal-access-token](images/enable-personal-access-token.png)
4. Go to the Profile and create Personal Access Tokens on the Security tab. The Access Token is used for the ivy variable configuration.
![create-personal-access-token](images/create-personal-access-token.png)
5. Enable Bot Account Creation and create a bot account for sending notification to the channel Axon Ivy. E.g. axonivy-bot
6. Create a slash command in the Integrations menu.
![create-slash-command](images/create-slash-command.png)
7. Create a incoming webhook for the channel that the axonivy can use and post data to the selected channel.
![create-incoming-webhook](images/create-incoming-webhook.png)

Add the following `Variables` to your `variables.yaml`:

- `Variables.mattermost.baseUrl`
- `Variables.mattermost.accessToken`
- `Variables.mattermost.teamName`
- `Variables.mattermost.botName`

and replace the values with your given setup.

```
@variables.yaml@
```
