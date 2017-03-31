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


Running the MagCrawler(v3)
-----------

The MagCrawler is a crawler designed to get information (links and other data) from the public articles inside a magazine and register it to a database. It does not have a final version because every single magazine has it's particularities.
To run it (at a command shell), go to the philbrasil_res folder and type:
```shell
rails runner magcrawler/mag_crawler_v3.rb
```

The Architecture
----------------

While Rails is an agile development framework, a basic architecture needs to be in place to avoid breaking the 'single responsibility' concept. For that, instead of using a lot of model/service/business logic into the controllers and making it as big as the system grows, poisoning any will to support this project, we introduce more layers to the development. These are (down-top):
> - DAOs: the layer that will make use of Rails' ActiveRecord on querying, saving, and editing data to the disk (to the database)
> - Services: used to use the return from DAOs, i.e. data from the database, and apply the business logic to it, passing the results of these logics and calculations to the facades.
> - Facades: used to compact the code reading by coupling services together when needed, and finally, building the correct data to show to the user beyond the controller layer.

The pros:
> - more readability
> - single responsibility
> - easier to maintain
> - based on the good old fellas, the design patterns
> - nice testability
> - DRY (don't repeat yourself) principle

The cons:
> - when adding new feature, probably it will need to be built by separating all it's logic into these layers, what can lead to deal with various classes/files at the same time (but if you are a programmer you should be used to it ;P )


<sup>1</sup> Maybe you need to update PATH or the gem executables will not run. Add `export PATH="$PATH:$HOME/.gem/ruby/2.3.0/bin"` to your .bashrc or .zshrc, before you install the bundles.
