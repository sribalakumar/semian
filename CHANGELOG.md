# v0.7.0

This change introduced a series of changes to support a new "dynamic quota" ticket
allocation strategy. This code primarily affects bulkheads (protected resources).

Rather than statically setting a ticket count, workers (in their own process) now register
themselves. By specifying 'quota' instead of 'tickets', the bulkhead threshold will now be
computed dynamically as a ratio of the number of registered workers, eliminating the need to
continuously readjust ticket counts, and supporting environments with non-uniform worker
distribution between machines.

* Feature: Support quota based allocation strategy (#120)
* Feature: Add ability to manually unregister workers (#130)
* Feature: Add ability to clear resources from adapters and unregister all resources (#134)
* Feature: Allow sysV IPC key to be accessed in ruby (#136)
* Feature: Expose registered worker count to ruby (#137)
* Refactor: Allow registered worker count to be accessed through bulkhead (#138)
* Bug fix: Register all workers (#128)
* Bug fix: Lazy instantiate redis clien on first I/O (#132)
* Bug fix: New mysql error (#131)
* Refactor/Feature: Break coupling between resource and circuit breaker (#123)
* Refactor: Use generic max_sem_val (#117)
* Refactor: Fix header syntax (#118)
* Refactor: Always acquire semaphore without_gvl (#121)

# v0.6.2

*  Refactor: Refactor semian ticket management into its own files (#116)
*  Refactor: Create sem_meta_lock and sem_meta_unlock (#115)
*  Refactor: Refactor semaphore operations (#114)

# v0.6.1

* Refactor: Generate a unique semaphore key by including size of semaphore set
* Refactor: Refactor semian\_resource related C functions
* Fix: Don't require sudo for travis (#110)
* Refactor: Refactor semian.c includes and types into header files
* Fix: Use glob instead of git for gemspec file list
* Fix: Fix travis CI for ruby 2.3.0 installing rainbows
* Refactor: Switch to enumerated type for tracking semaphore indices
* Docs: readme: explain co-operation between cbs and bulkheads
* Docs: readme: add section about server limits

# v0.6.0

* Feature: Load semian/rails automatically if necessary
* Feature: Implement AR::AbstractAdapter#semian\_resource

# v0.5.4

* Fix: Also let "Too many connections" be a first class conn error

# v0.5.3

* Fix: mysql: protect pings
* Fix: mysql: match more lost conn queries

# v0.5.2

* Fix: Make request\_allowed? thread safe
* Fix: Fix CI connect errors on HTTP requests by using 127.0.0.1 for host

# v0.5.1

* Fix: Assert Resource#initialize\_semaphore contract on Resource init
* Fix: Lock on older thin version for pre MRI 2.2 compatibility

# v0.5.0

* Fix: Only issue unsupported or disabled semaphores warnings when the first resource is instanciated
* Refactor: Cleanup requires
* Maintenance: Use published version of the toxiproxy gem
* Fix: Fix minitest deprecation warnings
* Maintenance: Update bundler on travis
* Maintenance: Update supported MRI versions on travis

# v0.4.3

* Fix: Fix lazy aliasing of Redis#semian\_resource
* Fix: Workaround rubocop parser limitations

# v0.4.2

* Fix: Fix for TimeoutError is deprecated in Ruby 2.3.0
* Feature: Include Ruby 2.3 in Travis builds

# v0.4.1
* Fix: resource: cast float ticket count to fixnum #75

# v0.4.0

* Feature: net/http: add adapter for net/http #58
* Refactor: circuit_breaker: split circuit breaker into three data structures to allow for
  alternative implementations in the future #62
* Fix: mysql: don't prevent rollbacks on transactions #60
* Fix: core: fix initialization bug when the resource is accessed before the options
  are set #65
