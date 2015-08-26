# Architecture

This chapter explains some of the decisions that led to the final architecture.
The most challenging parts and implementation details, along with the specifications
and database schema were structured in the form of sub chapters.

As part of the objectives, the main focus was to build something simple
and low in requirements. The purpose of this architecture is at some point to
become a fully self-sustainable federated network of nodes, each communicating
with each other using the web technologies and web protocols.

## Preliminary Decisions

Some of the questions I had to answer were related to the final storage
technology that will be adopted, along with the programming language and
the framework/toolset that will be used to build and deliver the components.

Researching the storage options, I opted for PostgreSQL. Beside this being the
most advanced open source database, it offered a set of reliable features that
can be used on in order to provide key-value storage along with the relational
entities. Studying the database pub-sub[^pgnotify] implementation it was clear
this can reduce the technology in the stack. I will go in more details on how
these aspects of the database were used in the next chapters.

The framework/toolset needed to build the application required to follow the
RAD[^rad] approach because of the amount of prototyping I was estimating. I
also needed a programming language with a community and an ecosystem oriented
towards the most cutting edge web technologies, but with a decent stability
and clear future.

I settled on the Ruby programming language and Ruby on Rails web framework. The
Rails community has a great impact on the web technologies and tools. This was
proven by solutions like Sass[^sass] and Haml[^haml] and large scale adoption
was concepts like ReST[^rest]ful Model-View-Controller,
ActiveRecord[^activerecord] object-relational mapping, and test driven
development and behaviour driven development.

## Database schema

During the database design I tried to apply the same principles as in case of
the overall architecture so that to keep things as simple as possible.

### Conversations

The way I decided to organize the data users exchange is in the form of conversation.
The conversations are the simplest units that keep the data organized. Compared
to email, conversations would represent messages, but with a very big difference.

The conversation model is very normalized compared to the monolithic email
message format. But it is a little more complex compared to a chat message. A
conversation knows about its participants, messages, attachments and other
details. When users will want to send a message to somebody, they will start
a conversation.

The way this conversation carry information is through its messages. Messages
are a separate model in the schema and represent the text users exchange inside
a conversation. These messages can have replies and attachments.

While replies also represent messages, attachments are absolutely different.
Attachments, just like messages, belong to an user. This solves the privacy
questions where an individual involved in a conversation, would forward on his
own behalf information without owners concern. But also structure and separate
types of attachments by leveraging single table inheritance.

From the storage point of view, all the attachments look the same. A file and
an event are stored in the same table. This is possible thanks to the concept
of single table inheritance. From the functional point of view, a file behaves
different from the event attachment type. This is possible by using the
key-value storage provided by the PostgreSQL database and called ``hstore``.
Thanks to this technology a key-value document can be defined as a database
table column. The application defines the following attachments types:

 * uploads, abstract interface to handle file uploads to cloud services
 * timestamps, used to represent event informations
 * links, used to store and cache an HTTP URI[^uri] meta-data
 * locations, used to store and display geographic locations
 * task lists, simple set of items to organize and track objectives

The list can be extended with very little effort, although the initial
functionalities can be considered some of the most popular things individuals
exchange using email.

In order to provide end-users with a way to highlight important messages in the
long conversations, the concept of a summary is handled by the model with the
same name. A summary has many messages and attachments that ends up looking
like a report. Such a report can be shared with collaborators without breaking
any privacy rules since the only specific messages can be included in it.

### Collaboration aspects

Collaboration functionality is represented by the user models which carry
ordinary information about the individuals. An important aspect of this is that
authentication information is not part of the user data.

The approach I took here can be called the identity based authentication. And
the biggest difference to the traditional approach where the credentials are
stored along with the personal data is that the authentication becomes
pluggable. As an example, the individuals can use different kind of
authentication forms, from the classical password based authentication, to the
more complex third-party providers using a handshake or token to provide login
sessions.

The memberships model serves to provide information on which user has access to
which conversation. Where friendship model, which uses the membership through
the single table inheritance, provides information on which user know about
each other, this way providing the minimum networking aspects.

In order to ask users to join conversations or discover other users, the
invitation model was designed. This handles the information on what type of
membership user is asked to join by using a polymorphic association on
membership and friendship entities.

The collaboration design was also structured keeping in mind the fact that
one application can communicate with another one, thus creating a federated
architecture of resources that share common conversations. Although further
work on this aspects was not done and is not included in this document.

### Real-time aspects

To solve the aspect of the real-time communication, the database publish-subscribe
functionality was used. This will be explored further in the implementation details.

An important note in regards to the real-time transport of the data is that
keeping the database entities small, helped further simplify the implementation
and speed up the transfer during the synchronization and initial load of the
data on the client.

Providing small segments of data had a great impact on the simple design of
the web API specifications and API endpoints.

\includegraphics[scale=0.39]{erd}

### Synchronisation aspects

In order to build a decentralized system, the application should provide
identification information for its data models, so that a synchronisation
process can avoid data conflicts or duplication. The initial work towards this
was to provide unique identifiers for conversation related models and
collaboration related models. In this case, a conversation carrying a unique
identifier and owned by a user with a unique identifier can be easily tracked
by a synchronisation process. I used universally unique identifiers (UUIDs),
attached to the relevant models as a temporary solution until more work is done
in order to support this functionality.

## Web API

After reviewing the proposed objectives, the perspective of building the
solution as a monolithic application that would handle the user interface and
the back-end business logic was no longer approachable. Moving towards a
decentralised architecture would require splitting the user-facing component
from the rest of the services. A protocol to provide the communication between
these two is also required.

Beside the architectural considerations, approaching the problem from a position
where specifications and services implementation is placed in the front row,
and user experience is considered a secondary aspect, didn't sound to
lead to better results. This factor influenced the architectural decision
of building the client interface and iterating over it until a better user
experience is achieved, to become the starting point of the implementation stage.
While the back-end or services implementation stage would have to follow up
with the user-experience requirements. I will develop this subject also in the
next chapter.

In order to to design a protocol for the modern world distributed services, the
Web API programmatic interface is considered one of the most common approaches
lately. Web application programming interface build as a ReSTful architecture
would not only allow us to provide open specifications to the future consumers
but also allow potential developers to build upon it alternative clients or
extend exiting features.

### Endpoints

Having the models defined and following the ReST architecture allowed to
easily deliver the most of the API endpoints and focus on the specifications
of each endpoint. The content type used to consume the API endpoints is JSON
because of the human-readable and lightweight format.

The endpoints were structured under a version namespace a prefixed with the
``api`` keyword. The version namespace allows further improvements and
deployments of the endpoints without any chance of breaking changes for older
consumers of the same API.

Although the idea of nesting some of the endpoints sounds appealing, it proved
to increase complexity when working with such endpoints as a consumer/client.
The biggest challenge with nested endpoints is to generate the correct paths
for resource URIs.

The authorization for all the endpoints is done by providing an expiring token
as part of the HTTP request parameters or the HTTP headers. This approach is
also common for ReSTful APIs and has a minimal impact on both, the complexity
of the system and the client development. Enforcing an expiring token also
consolidates the security aspect of the API without requiring an end-user to
change his authentication credentials on a regularly basis.

By using Rails web framework the endpoints are handled by controllers and
are very expressive. This was possible by following a programming pattern
encouraged by the framework community and called _Skinny Controller, Fat Model_[^fatmodel].
Following this practice results in a cleaner, more maintainable and testable
code-base. I will list the conversations controller source code in order to
provide an example of the final result.

```ruby
# API (v1) Conversation controller class
class Api::V1::ConversationsController < Api::V1::ApplicationController
  # Lists available conversations
  def index
    conversations = current_account.conversations.where(:slug => params[:ids])
    render :json => conversations
  end

  # Lists a conversation
  def show
    conversation = current_account.conversations.find_by!(:slug => params[:id])
    render :json => conversation
  end

  # Create a conversation
  def create
    conversation = current_account.conversations.build(
      new_conversation_params.merge(:user => current_account))

    if conversation.save
      render :json => conversation
    else
      respond_with_bad_request(conversation.errors)
    end
  end

  private

  # Parameters for creating a new conversation
  def new_conversation_params
    params.require(:conversation).permit(:title)
  end
end
```

The controller exposes endpoints to fetch available conversations as a
collection or as a single resource, and create a new resource. Below is a
listing of the HTTP methods and the endpoint paths generated by the ``rake
routes`` command from the application. You can see how the method names fit the
HTTP methods along with the endpoint paths.

|Verb    | URI Pattern                | |Verb    | URI Pattern                |
|--------|----------------------------|-|--------|----------------------------|
|`GET`   | `/api/v1/attachments`      | |`GET`   | `/api/v1/messages`         |
|`POST`  | `/api/v1/attachments`      | |`POST`  | `/api/v1/messages`         |
|`GET`   | `/api/v1/attachments/:id`  | |`GET`   | `/api/v1/messages/:id`     |
|`PATCH` | `/api/v1/attachments/:id`  | |`PATCH` | `/api/v1/messages/:id`     |
|`PUT`   | `/api/v1/attachments/:id`  | |`PUT`   | `/api/v1/messages/:id`     |
|`GET`   | `/api/v1/conversations`    | |`GET`   | `/api/v1/memberships`      |
|`POST`  | `/api/v1/conversations`    | |`POST`  | `/api/v1/memberships`      |
|`GET`   | `/api/v1/conversations/:id`| |`GET`   | `/api/v1/memberships/:id`  |
|`GET`   | `/api/v1/invitations`      | |`DELETE`| `/api/v1/memberships/:id`  |
|`POST`  | `/api/v1/invitations`      | |`GET`   | `/api/v1/summaries`        |
|`GET`   | `/api/v1/invitations/:id`  | |`GET`   | `/api/v1/summaries/:id`    |
|`PATCH` | `/api/v1/invitations/:id`  | |`GET`   | `/api/v1/socket`           |
|`PUT`   | `/api/v1/invitations/:id`  | |`GET`   | `/api/v1/users`            |
|        |                            | |`GET`   | `/api/v1/users/:id`        |

### API specifications

Each endpoint representing a single resource uses a serializer to generate the
data in JSON using a common set of specifications. The initial draft of the
specifications used by serializers was inspired from the JSON-API[^jsonapi]
project initiative, although the most recent version is highly different from
what is used in the project.

Writing the specifications for the endpoint payloads, I followed some of the
conventions where the main highlights are:

 * always provide a root key for the payload (usually matches the resource
   endpoint), this helps embeding meta information aside from the expected data
 * keep the payload normalized, thus providing the associations using the
   relevant identifiers
 * embed records of different types in the same payload when possible to
   reduce the number of requests and client waiting time.


A serializer can be considered as a light wrapper that uses the specifications
and generates machine or human readable data without requiring the manual
intervention to handle different formats or switching from one format to
another based on the content type negotiation mechanism.

A serializer usually has a very simple structure and can be extended using
inheritance. Below is a listing of the same conversation serializer.

```ruby
# Conversation class serializer
class ConversationSerializer < ActiveModel::Serializer
  root :conversation

  attributes :id, :title, :created_at

  has_one :user, :embed_key => :slug, :embed_in_root => false
  has_one :summary, :embed_key => :slug, :embed_in_root => false
  has_many :messages, :embed_key => :slug, :embed_in_root => false
  has_many :participants, :embed_key => :slug, :embed_in_root => false

  # Mask the id with the slug value
  def id
    object.slug
  end
end
```

If we looks at the naming of the controller and the serializer, we can see that
it follows the same pattern. This is a Rails convention and it helps keeping
things organized without too much coupling logic. Below is a listing of a
response from the conversations controller.

```json
{
  "conversation": {
    "id": "832f94a9af",
      "title": "Ola",
      "created_at": "2015-08-23T21:13:03.202Z",
      "user_id": "8a7efd0f1a",
      "summary_id": null,
      "message_ids": ["e580fceb1d", "4a0d334572", "ee193ae989", "5eb0bc38d0"],
      "participant_ids": ["8a7efd0f1a"]
  }
}
```

## Real-time communication

In order to provide a mechanism that will enable real-time communication
between the application and a third-party consumer (this can be a client or an
another node in the network) we need to know when a new message arrived and
send it over to the relevant recipient.

This description fits very well the messaging queues purpose, but messaging
queues usually require a broker. This broker is usually a service that knows
how to route the message to appropriate receivers. During the design of the
architecture this aspect was delegated to the database itself by using the
PostgreSQL `LISTEN` and `NOTIFY` commands.

### Routing and the announcement of the updates

The way `NOTIFY` works, provides an asynchronous way to announce new messages
for subscribers of a channel. The channel is simply an identifier to group
messages and route these to subscribers with the same identifier. In our case
the subscribers can be described as conversation participants and the messages
can be represented by the type and database identifiers of the new content
submitted by the conversation participants.

By having the database normalised, the application message needs to provide
just a minimal amount of the information about the data that was updated or needs
to be synchronised. In our case, sending notifications about new conversation
messages will also provide relevant information about the participants and
attachments.

```ruby
# Support for notifications
module Notifier
  # Support for concerns
  extend ActiveSupport::Concern

  included do
    after_create :notify_channels
  end

  private

  # Generates a payload to be sent on notify
  # @return String comma delimited values of form `Class, ID`
  def payload
    self.class.connection.quote([self.class.name, self.id].join(','))
  end

  # Callback to notify one of the channels
  def notify_channels
    notification_channels.each do |channel|
      self.class.connection.execute('NOTIFY %s, %s' % [channel, payload])
    end
  end

  # Returns a list of channels to be notified
  # @return Should return an array with string values of form `['user_ID']`
  def notification_channels
    []
  end
end
```

In the code listing above, a callback is triggered for the newly created
conversation messages. This callback gathers information about the payload and
serializes it in the form of `<type>, <id>`, and about the channels this
payload needs to be distributed. The channels are the conversation participants
serialized in the form of `user_<id>`. The `Notifier` module is used by the
messages model and overwrites the private method
`Notifier#notification_channels` to provide the relevant information.

### Delivery of the updates

Before describing the implementation details of how the messages arrive to the
subscribers, I need to describe the web technology used to provide the transportation
of the messages.

The nature of this functionality requires a subscriber to be connected to the
right channel in order to receive updates. HTTP is not a reliable option and in
the next chapters I will address this question separately. But HTTP version 1.1
provides a mechanism called _upgrade header_ in order to allow clients to
establish a connection in a compatible way. One of the protocols that is
supported and can be used to provide a more robust connection is called
WebSocket. This protocol provides a full-duplex communication over a single
TCP connection and it works in a similar manner with a message queue by using
channels. Although WebSocket is an independent protocol, it is considered a web
technology and is supported very well.

To dispatch the updates the application uses the WebSocket protocol along with
the already mentioned PostgreSQL `LISTEN` command. The `LISTEN` command is not
blocking and it works more like a registration call, announcing the server that
any messages to a specific channel should be sent to this connection too. In
order to de-register, or unsubscribe from a certain channel `UNLINSTEN` command
is available and uses the channel as the parameter. The connection receives the
messages using the `select` API method afterwards which is blocking. The data
received by the connection socket is processed and materialized into a model
object. The code listing below represents the implementation of the database
relevant aspects.

```ruby
# Support for listening
module Listener
  # Support for concerns
  extend ActiveSupport::Concern

  # Listens to the channel for notifications and yields if any
  def on_notifications
    self.before_listen if self.respond_to?(:before_listen)

    self.class.connection.execute('LISTEN %s' % channel)
    loop do
      handle_notifications do |incoming|
        yield incoming
      end
    end
  ensure
    self.class.connection.execute('UNLISTEN %s' % channel)

    self.after_listen if self.respond_to?(:after_listen)

    # Make sure we close this connection since its thread will be killed!
    self.class.connection.close()
  end

  private

  # Listens and handles any incoming notifications
  def handle_notifications
    self.class.connection.raw_connection.wait_for_notify do |ev, pid, payload|
      if parsed_payload = parse_payload(payload)
        yield parsed_payload
      end
    end
  end

  # Handles payload
  # @param String payload
  # @return Object
  def parse_payload(payload)
    payload_class, payload_id = payload.split(',')
    if payload_class and klass = payload_class.safe_constantize
      klass.find(payload_id.to_i) rescue nil
    end
  end

  # Returns the channel to listen to
  def channel
    '%s_%d' % [self.class.name.downcase, self.id]
  end
end

```

The materialized model object is finally dispatched to the client using
WebSocket as a JSON serialised string. The format of data coming through the
WebSocket follows the specifications and in fact uses a slightly modified
serializer, mostly to include as much data as possible.

```ruby
# API (v1) misc controller class
class Api::V1::MiscController < Api::V1::ApplicationController
  # Websockets support
  include Tubesock::Hijack

  # Streams available activities
  def websocket
    hijack do |tubesock|
      # Listen on its own thread
      socket_thread = Thread.new do
        current_account.on_notifications do |obj|
          tubesock.send_data _render_option_json(
            obj, {:serializer => UpdateSerializer})
        end
      end

      tubesock.onmessage do |msg|
        tubesock.send_data _('Error: 405')
      end

      tubesock.onclose do
        # Stop listening when client leaves
        socket_thread.kill
      end
    end
  end
end

```

In the listing above is the controller implementation responsible for the
`/api/v1/socket` endpoint, which is where WebSocket clients will connect to.
Because of the blocking aspects of how the messages are received by the
database connection, in order to keep the WebSocket alive until the client
disconnects, the controller starts a thread and runs the delivery of the
messages inside it. The thread is stopped when the WebSocket client disconnects
and the database connection is either closed or returned to the connections
pool in order to be reused.

## Scaling concerns

One of the aspects of the communication software is that it usually needs to
handle a lot of users in order to actually make possible the communication. And
although in our case the objectives stated that the initial purpose of the
application is to provide services in small teams, the overall architecture
needs some clarifications in regards to how small is a team until it is a big
one and how this can be addressed when it happens.

The main limitations of the real-time mechanism rely mainly on the number of
the connections the database can allowed to handle. In PostgreSQL, the
`work_mem` configuration directive is 1MB by default and represents the amount
of memory a database connection can use. Knowing this it is easy to estimate
and increase the maximum amount of connections the database server will handle.
In case of larger installations an external brokerless non-persistent messaging
queue solution can be adopted (ZeroMQ[^zeromq] or nanomsg[^nanomsg] to name a
few), replacing the current direct communication of a WebSocket with the
database, and instead, connecting to the message queue service.

## Testing

Automated testing using the BDD testing framework RSpec was used to make sure all the
specifications and functionalities work as expected. Unit tests were provided
for models and integration tests for the controllers.

For evaluation purposes of the application functionality, a client was also
written. And although I will present the evaluation results in the next
chapter, the client was used to write and run functional tests.

To run the functional tests, a headless browser engine was used to load the
application client and make sure it works with as would a user use it. This
approach allows testing the client and directly the application in different
user environments: from different operating systems to different browser
versions and engines.

Finally a continuous integration server was used to run the tests against every
change that was made along the development process. Continuous integration
proved to be a great tool helping to reduce the number of regressions and bugs
without too much effort.

## Deployment
