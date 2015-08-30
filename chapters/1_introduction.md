\mainmatter

# Introduction

Electronic mail or simply email, is currently the most wide-spread adopted
solution for exchanging digital messages on internet. This technology was
designed in 1970s and since then it almost did not change. The technological
challenges, market share and social responsibility that would imply replacing
or improving the email attracts lots of minds and companies today.

Some of the proposed alternatives for asynchronous or real-time internet
communication do a great job on improving on the problems email carries, but at
the moment there is no silver bullet to consider this subject closed. This
among other things could be explained either by user reluctance to new things
or simply by lack of usability and huge complexity of the alternatives.

In 2013 I cofounded a technical startup which started addressing the problem of
an email alternative. My responsibilities among other things were to architect
and build a web application that could work as a better tool to communicate
inside smaller teams. On eventual success, this tool would become a new
_protocol_ to make the communication possible between other teams. Thus
representing an alternative to the email. All the work was open sourced in 2014
due to us failing to find funds for further development and traction.

## Email

So what is wrong with the email?! Besides being a very popular internet service,
this technology carries a lot of complexity and legacy aspects. It has a long
history, but reading it will not reveal innovative or interesting technological
progress. On the other hand, the core of this technology is still present in
almost every other service on the internet. So the biggest question I am asking
myself here is if it _is possible to have an internet without the legacy of the
email as we know it_.

In the next chapters I picked some of the core email components that represent
the email as the technology. This work challenges and objectives are a result
of studying these components and designing a hopefully better alternative.

### Server components

From the email software, the email client, also called as the mail user agent
(`MTU`), is the only part that does not require a server. In the same time, you
can not really do anything with just that. Email can be described as a
centralized service. This means you will need a central server to connect to in
order to fetch your messages or to send new.

\includegraphics[scale=0.24]{email}

Above is a simplified illustration of how email as the service operates. The
simplified email server requires the presence of two components:

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

Although most of the email server software solutions come with bundled a `MTA`
and `MDA` the way these components operate can be different from one host to
another. The policies implemented for every incoming or outbound message also
differ from one server to another. And the storage for the final mail, although
is not standardized, went through all kind of formats: from local file systems
to encrypted databases and to cloud-based high-availability distributed network
file systems.

### Message format

In order to demonstrate how email is a legacy technology, one can use the
message format as an example. The fact that this is usually just text and
can be easily visualised, does not mean it is simple to understand.

The email format consists of two major sections, **the header** and **the body**.

The header of the email consists on its own of multiple fields. All these
fields provide information about the sender, recipients, subject and other less
common details. The amount of headers a message can have, vary. This is not
dependent just on sender and the software used to send the message. The message
headers change or can be extended depending on various aspects and policies
enforced by each and every server it passes through. All of the message
attachments are also part of the header.

The body of the email contains text, therefore the content encoding of the body
is crucial in order to preserve the original data. The content of the body can
be plain text or ``HTML``.

## Motivation

Despite its huge popularity, the email as a business and personal internet
communication solution was many times criticized for its limitations and
problems. By focusing on the email aspects I described above, it is worth
mentioning the following problematic aspects of the email as a
software[^email].

#### Complexity and technical debt

The complexity of the email systems is very high. Just the number of RFC[^rfc]
publications related to the email, is a very long list[^emailrfcs]. Working
with this amount of specifications today can take a lot of time and resources.
It is hard to believe that an organisation can follow all these standards and
limitations and provide a solution that will work better, will be easier to
install or will be more flexible and fit the modern consumer.

The technical debt resides in the amount of the documentation and software that
was mainly designed and implemented long time ago. This software went
through different operating systems and programming language versions. Some
of that software is simply no longer relevant because of the minority of the
platforms or operating systems it was designed for.

Installation and deployment of the email software components is a very tedious
and error-prone process. Testing an installation usually requires a fully
set-up server or even two. These aspects, although are easier to provide using modern
virtualization technologies and software containers, are still troublesome to
test or automate for testing.

With this in mind, exploring a solution that will provide a backwards
compatibility to current email software stack is no longer an option for a
young and modern company. This was the main reason we decided to look
differently at the problem.

#### Attachments

The current email format provides support for attachments. This support has
no limitations in size, content type of the attachments and privacy aspects.

A common problem is when an email message that was sent is rejected by the
server due to server policies. These policies vary from one server to another.
End-users can only hope their message fits their email server policy since
there is no way either to get an instant validation of the attachment they want
to include.

Email attachments also result in a lot of space waste. Even though persistent
storage got cheaper with the cloud technologies, a lot of institutions are limited
to self-hosted solutions because of the nature of their business, like
healthcare and governmental institutions.

#### The Inbox Zero dilemma

The amount of email people receive on average every day continues to
grow. This became an issue especially for institutions and individuals where
most of their work is depending on the internet communication. Employees spend
more and more time trying to read and reply to the messages they receive
without being able to control the priority and importance of the content of
their messages. The Inbox Zero[^inboxzero] approach is one of the techniques
developed to fight the time spent reading email due to email overload.

I consider the email overload situation, a reflection of its bad
design. The inability to control your incoming email is also considered a
privacy issue.

#### Spamming and other internet email threats

The lack of control over the sender of the email message, resulted in
unsolicited number of messages to keep growing over time. Spam is unsolicited
email that can contain commercial information, phishing messages or attachments
containing viruses.

Phishing messages can look like genuine emails from important entities asking
for sensitive information. These messages trick victims to provide personal
details on credit cards and internet resources they use leading to online
frauds.

At this moment, the only solution to fight these problems is to develop or
adopt complex solution that automate verification and filtering of such
unsolicited email.

#### The privacy concerns

Email messages generally are not encrypted. The solutions provided to apply a
level of encryption depend on complicated tools that require, both the sender
and the receiver to share a private and a public key to decrypt the messages.
In order to help with this problem, solutions like Mailvelope[^mailvelope] were
designed. But mailvelope is not enforced and can not be enforced by the server
components. In fact, most of the email client applications, do not provide or
use a third-party solution for encrypting the messages. And although the email
sending and receiving protocols can leverage secure network protocols like
`SSL`, this solves only half of the problem.

The content of the messages not being encrypted can be forwarded to
third-parties without senders approval. This includes the attachments of the
emails too. Not being able to restrict or manage the access to the message, can
lead to information leakage or legal exposure in some context.

Providers of the email services also have access to end-user accounts which
makes it even hard for an individual to control the access to his data.

At this moment, there is almost no legal coverage to address the privacy
concerns of the email users. The existing initiatives are very limited and do
not apply globally.

## Alternatives

The idea of improving or replacing the email as a technology is not new.
Previously there were startups and technologies built in the hope of solving
the same problem.

Some of the best ideas encouraged the usage of a chat technology with IRC[^irc]
or XMPP[^xmpp] protocols in a working environment. With time these protocols
usage has been declining. Things eventually evolved into chat applications that
communicate using HTTP[^http] mainly.

Other solutions include document oriented or task based real-time
collaboration. Some of those restricted to private networks with proprietary
protocols.

## Objectives

After studying the main features of the email and potential alternatives, the
general idea was to create an exclusively web based server application that
works with JSON[^json] as the main format of the messages.

The format of the messages would support an extensible base schema. The
attachments would have their own schema designed with the privacy concerns in
mind. Using real-time web technologies the delivery of the messages
would happen instantly if a receiver is logged in.

The server architecture would require the minimum of resources and dependencies
to run. It would be easily upgradable and scalable. And it would be designed as
a simple technology to understand and use, for both, the users and the
developers.

To test and gather end-user feedback, a simple client should be implemented in
the form of a thin-client. The client itself should be independent from the
server.
