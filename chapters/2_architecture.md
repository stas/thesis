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
RAD[^rad] approach because of the amount of prototyping I was expecting. I
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

\includegraphics[scale=0.4]{erd}

## Web API

## Real-time communication

## Scaling concerns

## Testing

## Deployment
