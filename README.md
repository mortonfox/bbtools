# bbtools

bbtools is a set of scripts to do simple things with Bitbucket. Currently,
there is only backup\_repos.rb, which downloads all of a user's repositories
and produces a git bundle and a zip file for each repository.

## Installation

bbtools uses the rest-client and netrc gems. Run the following to set up
prerequisites:

```
gem install rest-client netrc
```

## Authentication

Although bbtools will work fine without Bitbucket authentication, it won't be
able to access private repositories.

bbtools uses the [netrc gem](https://github.com/heroku/netrc) to retrieve
login credentials from a
[.netrc file](http://www.gnu.org/software/inetutils/manual/html\_node/The-\_002enetrc-file.html)
in your home directory.

If you do not have two-factor authentication set up, adding your Bitbucket
password to the .netrc file would work. However, I suggest using an app
password instead because it is easy to revoke if there is a security breach.

To generate an app password:

* Log in to Bitbucket. <https://bitbucket.org/account/signin/>
* In your dashboard, click on your user icon and select "Bitbucket settings".
* Click on "App passwords".
* Click on "Create app password".
* Enter "bbtools" in the label. Select "Repositories / Read" and "Account / Read".
* Click on "Create".
* Copy the app password from the popup dialog.

Add the following to the .netrc file in your home directory:

```
machine bitbucket.org
    login bb-login
    password bb-app-password

machine api.bitbucket.org
    login bb-login
    password bb-app-password
```

where ```bb-login``` is your Bitbucket user name and ```bb-app-password``` is
the app password you copied from the last step above. The information needs to
be added twice because the Bitbucket API uses api.bitbucket.org while git uses
bitbucket.org.

## Usage

### backup\_repos

Run this script with a username as the first argument. The script will do the
following:

* Create a folder named repos.
* git clone each of the user's repositories, excluding forks of other repositories.
* Create a git bundle of each repository.
* Run git archive to create a zip file of each repository.
* Delete the cloned repositories.

Warning: backup\_repos does not support Mercurial yet. It will skip any
Mercurial repositories in the user's account.
