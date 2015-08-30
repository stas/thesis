# Evaluation

In order to evaluate the results and the functionality of the application, an
application client was designed. In chapter 2, when working on the web API, I
mentioned that the user experience and the user interface played an important
role in the whole application design and implementation process. In fact, in
order to reduce the amount of work on the application, along with a designer
and a front-end developer, we started prototyping and iterating on the first
versions of the user interface and user flow. This development process is
possible thanks to programming languages like JavaScript and front-end
development frameworks like Ember.js[^ember].

## Client design

\includegraphics[scale=0.39]{welcome-screen}

At first, the welcome screen similarities with a generic email client seem very
present, but this is not entirely correct. In order to deliver some of the
changes that are entirely new concepts, we tried to make the user interface
changes less dramatic.

The side menu representing generally the email folders list was completely
rebuilt to simplify the access to the conversations. This menu also stores the
information about the user accounts, this way providing a common interface to
access work and personal accounts.

Based on the way conversations are usually done on email, the folders list and
the conversations list changed too. We came to the idea that a conversation on
email or internet messaging can be grouped in one of the following types:

 * inbox, meaning that this is a new conversation where somebody initiated a
   conversation with the user
 * ongoing, representing conversations in which currently the user is involved
   and a response from recipients is needed
 * archived, these conversations are not show, but can be found using the
   search.

Following these simple conversation states, we could show in an easier way what
is the general status of the user account.

\includegraphics[scale=0.39]{conversation-screen}

The conversation screen was completely redesigned with the goal to save the
user as much time and actions as possible. While the messages list looks
similar to an email thread, the message composer became a minimal text editor.
The composer area features a floating cursor. The cursor carries action buttons to add
attachments to the current message or mention/add participants from the friends
list. Attachments action opens a simple dialog and allows to embed one of the
available attachment types. All the options and navigation inside the editor
has intuitive keyboard support. Finally the text features markdown support and
the contact list supports auto-complete.

This screen also supports real-time updates coming from the web API. Where the
messages sent by participants show up instantly. This is very similar to the
instant messaging communication software.

## Client implementation

By using Ember.js to build the client, we could leverage its models that were
designed for ReSTful APIs. This way a model named _conversation_ will always
use the _conversations_ resource endpoints of the API and the appropriate HTTP
methods to create, delete or update a record.

In order to provide the client with the real-time updates we provided the
application with an initializer that connects to the application WebSocket
endpoint.

```coffeescript
Founden.initializer
  name: 'socket'
  initialize: (container, application)->
    return if (/127.0.0.1/).test(window.location.href) and
      !(/use_websockets/).test(window.location.href)
    return unless window.WebSocket

    adapter = container.lookup('adapter:application')
    store = container.lookup('store:main')

    endpoint = 'ws://%@%@'.fmt(
      window.location.host, adapter.buildURL('', 'socket'))

    # Register the container namespace
    socket = new WebSocket(endpoint)
    socket.onmessage = (event) ->
      if event.data.length
        data = $.parseJSON(event.data)

        # Try a later reload to see if there are any messages
        if data and data.message
          Ember.run.later {store: store, data: data}, (->
            @store.find('message', @data.message.id).then (message) ->
              message.didLoadFromPayload()
          ), 500

        store.pushPayload('message', data)
```

\newpage

This listing above includes the logic behind the initializer that handles
WebSocket messages and loads these into the client store. Ember.js uses an
identity map to keep the records of the models synchronised. Leveraging this
identity map we can push new records into the applications and the store will
normalize the entities and resolve any relationships to keep the map integral.

## User feedback

After the first release we started building an early adopters potential users
list. These users were our friends, colleagues and investors. We started
sending them invitations to register and try the latest release. In order to
understand their behaviour, we integrated a service that registers events based
on the actions users trigger. This is a simple principle where an action that
represents _started a conversation_ is mapped to the button _NEW CONVERSATION_
inside the application. Besides the user activity, we also stored basic
information on who were these users. This way we could get a partial picture of
how the application is used.

Unfortunately we managed to get only 8 new users. In this case besides us,
there was just too little activity generated to make an opinion if a certain
functionality is easy or hard to use for new adopters. We did received though
interest from developers after open sourcing the project. We consider, at
least, the results of our work to be experimental.
