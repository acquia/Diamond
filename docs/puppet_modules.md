# Puppet Module Structure
We're using a form of the Roles and Profiles pattern for handling how we
classify nodes. This makes it much easier to expose and control dependencies
and ordering problems between individual modules.

You should read the following links before attempting to create a new role or profile:
* http://www.craigdunn.org/2012/05/239/
* http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-2/

The summary you should take away from these posts are:
* Roles are containers for profiles. A server will only ever have a single
  role.
* Profiles are containers for **technologies**. Profiles can include other
  profiles where it makes sense to do so.
* Modules contain resources. This is where the actual work of configuring a
  service, application, etc. is done.
* Hiera is used for configuring modules and classifying servers.

Profiles should put ordering constraints on classes or virtual resources where
it is appropriate. This should make the `require` statement unnecessary in
modules unless you are requiring a class from within the same module. When
writing a module, you should never try and `require` or `include` a class from
another module and instead leave ordering and dependency management up to the
profile.
