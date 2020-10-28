# Ruby Integer API

This was a take home assignment that I completed as part of a take home test for
the interview process at a firm that I applied to.

The requirements were:

>## User Story
>### Incrementing Integers As A Service
>As a developer, I need a way to get integers that automatically increment so
that I can generate identifiers from within my code. I’m in a hurry and would
like to call a REST endpoint that returns the next available integer so that I
can get on with building my feature. Why I need to generate identifiers using
sequential integers is not important ;) Suffice it to say that this challenge is
based on a real-world scenario.
>
>### Your Task
>Develop a REST service that:
>- Allows me to register as a user. At a minimum, this should be a REST endpoint
that accepts an email address and a password and returns an API key.
>- Returns the next integer in my sequence when called. For example, if my
current integer is 12, the service should return 13 when it is called via the
​/next​ endpoint. The endpoint should be secured by an API key. I should not have
to provide the previous value of the integer for this to work. Fetching the next
integer should cause my current integer to increment by 1 on the server so that
if I call the endpoint again, I get the next integer in the sequence.
>- Allows me to fetch my current integer. For example, if my current integer is
12, the service should return 12 when it is called via the ​/current​ endpoint.
The endpoint should be secured by API key.
>- Allows me to reset my integer to an arbitrary, non-negative value. For
example, my integer may be currently 1005. I would like to reset it to 1000. The
endpoint should be secured by API key.
>
>### Stretch Goals
>- Build a UI for the service, especially the account creation functionality.
>  - Take it a step further and build the UI as a single page app that consumes
>    your API.
>- Allow sign up using OAuth
>  -G ithub, Facebook, Google—anything that supports it!
>- Deploy your API and include the link in your README so we can try it out
   without having to run it.
