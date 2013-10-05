# Mobu

[![Build Status](https://api.travis-ci.org/neighborland/mobu.png)](https://travis-ci.org/neighborland/mobu)
[![Code Climate](https://codeclimate.com/github/neighborland/mobu.png)](https://codeclimate.com/github/neighborland/mobu)

Mobu provides a Rails controller concern called DetectMobile.
Mobu does server-side User Agent detection to categorize requests as mobile, tablet, or default.
Mobu modifies your rails view paths based on the request type.

## Install

Add this line to your Gemfile:

```ruby
gem 'mobu'
```

Include the module in your ApplicationController:

```ruby
class ApplicationController
  include Mobu::DetectMobile
```

Create directories for `views_mobile` and `views_tablet`:

```sh
mkdir app/views_mobile
mkdir app/views_tablet
```

## Usage

Put the view/partial files that you want to override in the appropriate directories.

To allow mobile users to switch to the full site view, add a link to a mobile view:

```sh
app/views_mobile/_footer.haml
```
```haml
= link_to("View Full Site", prefer_full_site_url)
```

To allow full site users to switch to the mobile view, add a link to a default view:

```sh
app/views_mobile/_footer.haml
```
```haml
- if mobile_browser?
  = link_to("View Mobile Site", prefer_mobile_site_url)
```

## Credits

The view path modification techinique was taken from Scott W. Bradley's post
[here](http://scottwb.com/blog/2012/02/23/a-better-way-to-add-mobile-pages-to-a-rails-site/)

A similar project is Brendan Lim's [mobile-fu](https://github.com/brendanlim/mobile-fu)

