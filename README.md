PhilBrasil
===================
"Have you taken a prudence pill?" - Olegario, Gilson

**PhilBrasil** is a web project aimed to index/list links to portuguese based philosophical papers, articles, texts, paragraphs, and other related material.

----


Rails and Philosophy
------
Rails has an important position on how the web based projects have being made in the last 10 years. It's philosophy contains the agile development way of working and thinking. 

Because of these, aiming to be simple enough to understand and maintain, **PhilBrasil** is built upon this rock.

------

Download, Install, etc
-----
Well, you can download, install, edit and run **PhilBrasil** wherever and whenever you want. The following commands are supposed to work fine with linux.

> **Prerequesites:**

> - Ruby >= 2.2.2
> - Rails
> - Git
> - MySQL (you can change it if you want, but will need to search other place for it)
> - Bundler (gem install bundler) <sup>1</sup>
> - Nodejs
> - libmysqlclient-dev

```shell
git clone https://github.com/cgregoreki/philbrasil_res
cd philbrasil_res/
bundle install
rake db:create
rake db:migrate
rails s
```
The last line serves to initialize the local server on your machine. Then, to test it, open a browser and visit `localhost:3000`. If it fails (almost certainly), you'll need to configure the database.

> - Open philbrasil/config/database.yml
> - Replace the **username** and **password** to you current data.
> - Go back to the 'rake db:create' step above


Mailer Configuration
-----------

The mailer is configurated to work under development environment. However, you'll need to inform your credentials for your email account to use the service. For PhilBrasil, we are using the Google smtp server. So, the configuration is valid for this server. 

To put your credentials, open `config/environments/development.rb` and replace your credentials where indicated.
For the production environment, we aren providing any configuration. You should do it on your own. Good luck.

<sup>1</sup> Maybe you need to update PATH or the gem executables will not run. Add `export PATH="$PATH:$HOME/.gem/ruby/2.3.0/bin"` to your .bashrc or .zshrc, before you install the bundles.