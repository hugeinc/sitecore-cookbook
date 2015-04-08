Troubleshooting the Sitecore Chef Cookbook
==========================================
This file addresses common problems encountered by users of this cookbook.

Unable to Attach Database(s)
---------------------------
A FailedOperationException is thrown when attaching databases with the
sitecore_db resource:

    Exception calling "AttachDatabase" with "2" argument(s): "Attach database failed for Server [your server here]."
    ...
    FullyQualifiedErrorId : FailedOperationException

Ensure the user account running the Chef client has permission to create databases.

mixlib-shellout Gem Issues
--------------------------
Some users may get an error regarding the mixlib-shellout gem when running `bundle install`. Run `bundle update mixlib-shellout` to fix this problem.

See [Postmortem: ohai & mixlib-shellout gem release issues](https://www.chef.io/blog/2014/12/02/postmortem-ohai-mixlib-shellout-gem-release-issues/) for a more in-depth explanation of what's going on.
