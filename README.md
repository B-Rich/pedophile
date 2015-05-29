Pedophile
=========

Download static web pages.

Sample usage
------------

<pre><code>
p = Pedophile::Downloader.new

p.url = "http://www.classnamer.com/"

# clear tmp directory
p.wget.clear!

# sign in using devise like form
#p.login.devise_login("http://www.classnamer.com/login", "email@email.com", "password")

# download, process
p.make_it_so

# zip into single file in tmp/site/site.zip
p.zip("site.zip")
</code></pre>

If you would like change output directory *www.classnamer.com* to something nicer like
*super_site* and store in zip in different place, please remove:

```
p.zip("site.zip")
```

and add:

```
p.zip_with_custom_dir("/home/dude/super_offline_site.zip", "super_site")
```