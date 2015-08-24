# Architecture

This chapter explains some of the decisions that led to the final architecture.
The most challenging parts and implementation details, along with the specifications
and database schema were structured in the form of sub chapters.

As part of our objectives, the main focus was to build something simple
and low in requirements. The purpose of this architecture is at some point to
become a fully self-sustainable federated network of nodes, each communicating
with each other using the web technologies and web protocols.

## Preliminary Decisions

Some of the questions I had to answer were related to the final storage
technology we will have to adopt, along with the programming language and
framework/toolset we will use to build and deliver our components.

Researching the storage options, I opted for PostgreSQL. Beside this being the
most advanced open source database, it offered a set of features we could rely
on in order to provide key-value storage along with the relational entities.
Studying the database pub-sub[^pgnotify] implementation it was clear this
can reduce the technology in the stack. I will go in more details on how these
aspects of the database were used in the next chapters.

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
are a separate model in our schema and represent the text users exchange inside
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
attached to our relevant models as a temporary solution until more work is done
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

Having our models defined and following the ReST architecture allowed to
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

From the specifications, the main highlights are:

 *


## Real-time communication

## Scaling concerns

## Testing

## Deployment
