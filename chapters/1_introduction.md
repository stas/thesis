\mainmatter

# Introduction

Electronic mail or simply email, is currently the most wide-spread and adopted
solution for exchanging digital messages using internet. This technology was
designed in 1970s and since then almost didn't change. The technological
challenges, market share and social responsibility that would imply replacing
or improving the email attracts lots of minds and companies today.

Some of the proposed alternatives for asynchronous or real-time internet
communication do a great job on improving on the problems email carries, but at
the moment there is no silver bullet to consider this subject closed. This
among other things could be explained either by user reluctance to new things
or simply by lack of usability or huge complexity of the solutions.

In 2013 I cofounded a technical startup which started addressing the problem of
an email alternative. My responsibilities among other things were to architect
and build a web application that could work as a better tool to communicate
inside smaller teams and eventually provide an alternative protocol to make the
communication possible in between other teams thus representing an alternative
to the email.

All the work was open sourced in 2014 due to us failing to find funds for
further development and traction.

## Email

While the email as a service is pretty complex, in the following chapters I
will be focusing only on the major aspects of how the email works and what are
the limitations of some of those aspects.

### Server components

Email can be described as a centralized service. This means you will need a
central server to connect to in order to fetch your messages or to send new.

The simplified email server requires the presence of two components:

 * the ``MTA``, message transfer agent
 * the ``MDA``, message delivery agent

The message transfer agent is the software that can operate both as a client
and as a server in order to handle the transfer of the email messages from one
host to another. The client-server application architecture implements a
protocol called ``SMTP``, the Simple Mail Transfer Protocol. This protocol
allows email clients to send email messages.

The message delivery agent is the software that handles the local delivery of
the email messages from the message transfer agent to the recipient
environment. Usually the recipient environment is called a mailbox.

The modern message delivery agents also provide an implementation of the
``IMAP``, the Internet Message Access Protocol or the less complete ``POP3``,
the Post Office Protocol, or both of them. These protocols mainly allow email
clients to retrieve email messages from a remote server.

### Message format

The email format consists of two major sections:

 * the header
 * the body

The header of the email consists on its own of multiple fields. All these fields
provide information about the sender, recipients, subject and other
less common details.

The body of the email contains text, therefor the content encoding of the body
is crucial in order to preserve the original data. The content of the body can
be plain text or ``HTML``.

## Motivation

Despite its huge popularity, the email as a business and personal internet
communication solution was many times criticized for its limitations and
problems. By focusing on the email aspects I described above, it is worth
mentioning the following problematic aspects of the email as a software.

#### Complexity and technical debt

The complexity of the email systems is very high. The number of RFC[^rfc]
publications related to the email contains a very long list[^emailrfcs]. It is
hard to believe an organisation can follow all these standards and limitations
and provide a solution that will work, cost and look better.

The technical debt resides in the amount of the libraries and software that
was mainly designed and implemented by the same organisations that wrote the
email standards and protocols, thus convincing an entity like The Internet
Society to explore or introduce changes or new features can take a lot of time.

With this in mind, exploring a solution that will provide a backwards
compatibility to current email software stack is no longer an option for a
young and moder company.

This was the main reason we decided to look differently at the problem.

#### Attachments

The current email format provides support for attachments. This support has
no limitations in size, content type of the attachments and privacy aspects.

A common problem is when an email message that was sent is rejected by the
server due to server policies. These policies vary from one server to another.
End-users can only hope their message fits their email server policy since
there is no way either to get an instant validation of the attachment they want
to include.

The privacy limitations of the email attachments are also described in the next
sub chapter.

#### The Inbox Zero dilemma

In the last years the amount of email people receive on average continues to
grow. This became an issue especially for institutions and individuals where
most of the work is depending on the internet communication. Employees spend
more and more time trying to read and reply to the messages they receive
without being able to control the priority and importance of the content of
their messages. The Inbox Zero[^inboxzero] approach is one of the techniques
developed to fight the time spent reading email due to email overload.

#### Spamming and other internet email threats

The lack of control over sender of the email message, resulted in unsolicited
number of messages to keep growing over time. Spam is unsolicited email that
can contain commercial information, phishing messages or attachments containing
viruses.

Phising messages can look like genuine emails from important entities asking
for sensitive information. These messages trick victims to provide personal
details on credit cards and internet resources they use leading to online
frauds.

At this moment, the only solution to fight these problems is to develop or
adopt complex solution that automate verification and filtering of such
unsolicited email.

#### The privacy concerns

Email messages generally are not encrypted. The solutions provided to apply
a level of encryption depend on complicated tools that require, both the
sender and the receiver to share a private and a public key to decrypt the
messages. Although the email sending and receiving protocols can leverage
secured network protocols this solves only half the problem.

The content of the messages not being encrypted can be forwarded to third-parties
without senders approval. This includes the attachments of the emails too.

Providers of the email services also have access to end-user accounts which
makes it even hard for an individual to control the access to his data.

## Alternatives

The idea of improving or replacing the email as a technology is not new.
Previously there were startups and technologies built in the hope of solving
the same problem.

Some of the best ideas encouraged the usage of a chat technology with IRC[^irc]
or XMPP[^xmpp] protocols in a working environment. With time these solutions
usage has been declining and evolved in chat applications that communicate
using HTTP[^http] mainly.

Other solutions include document oriented or task based real-time collaboration
software suites but restricted to private networks with proprietary protocols.

## Objectives

After studying the main features of the email and potential alternatives, the
general idea was to create an exclusively web based server that works with
JSON[^json] as the main format of the messages.

The format of the messages would support an extensible base schema.

The server architecture should represent a simple and low in system
requirements. It should work as a distributed system and should be self
discoverable for other nodes.

The exchange and synchronisation of the messages between nodes should be
solved in a federated way, thus offering a decentralised and self-autonomous
service. Using real-time web technologies the delivery of the messages
should happen instantly if a receiver is logged in.

To test and gather end-user feedback, a simple client should be implemented
in the form of a thin-client thus its functioning should be independent from
the server.
