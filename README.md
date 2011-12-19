jistic - an api circuit breaker inspired by the Netflix circuitbreaker

jistic aims to implement a circuit breaker system as described by the
[Netflix blog post][post].

[post]: http://techblog.netflix.com/2011/12/making-netflix-api-more-resilient.html

The basic idea is that services consuming a remote API will report their
success or failures using that API to jistic. When a certain threshold
of failures are reached over a given timeslice jistic will notify all
users consuming that API that it is in failure mode.  It is up to the
individual services to figure out how to handle the failure case.

Once the services find the API server is back and operating properly
they will start notifying jistic and jistic will notify all other users.

# Getting started

Run the ./run script which will launch ./bin/jistic, zookeeper and kafka
in a screen session.
