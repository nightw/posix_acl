posix_acl Cookbook
==================

POSIX filesystem ACLs LWRPs in a cookbook for Chef

Usage
-----

#### ACL resource

Important restrictions:
* The user and the group attrbute cannot be used at the same time
* If the recursive attribute is set to true than the ACL setting will always run to ensure that all the subdirectories and files are set too

Examples
--------

This example uses all the possible attributes with the default values:

```ruby
posix_acl "/var/lib/foo" do
  user "john"
  group nil
  read true
  write false
  execute true
  recursive false
  default false
end
```

TODO
----

* Make it fully testable (preferably with Test Kitchen and Serverspec)

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Submit a Pull Request using Github

License and Authors
-------------------

Authors: Pal David Gergely <nightw17@gmail.com>

License: Apache Licence 2.0
