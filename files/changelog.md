### Changes

 - Moved params to being inherited in all classes
 - Changed server.pp to init.pp and changed class name
 - added an apache class that uses puppetlabs/apache module
 - removed non ssl site config
 - moved backuppc user to being created regardless if apache is handled by this module or not.
 - moved author from the file and moved to contributors.txt
