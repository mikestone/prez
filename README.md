# Prez

Simple single file HTML presentations.

## Installation

Simply install this gem:

    $ gem install prez

## Usage

If you want to create a new presentation:

    $ prez new MyPresentation

Modify the resulting template file, and build the final file:

    $ prez build MyPresentation

Copy the file where-ever you want and then run it by opening it in
your browser!

Alternatively, launch the presentation directly in your browser
without creating the HTML file:

    $ prez start MyPresentation

## Syntax

### Build a new slide

```erb
<% slide do %>
  <p>
    Contents of your slide!
  </p>
<% end %>
```

### Provide notes for your slide

```erb
<% slide do %>
  <p>
    Contents of your slide!
  </p>

  <% notes do %>
    These notes show up just for you while presenting this slide.
  <% end %>
<% end %>
```

### Add extra slide elements

```erb
<% slide do %>
  <p>
    Contents of your slide!
  </p>

  <% element do %>
    <p>
      A second slide element.
    </p>
  <% end %>

  <% element do %>
    <p>
      A third slide element.
    </p>
  <% end %>
<% end %>
```

Slide elements are pieces of a bigger slide that show up when you
advance to the next slide, but before actually moving to the next
slide.  The slide will not continue until all elements are shown.

By default, slide elements are represented as divs.  You can change
the tag that is used by providing it in the <code>tag</code> option,
or just embed the element directly and use the
<code>prez-element</code> class.

```erb
<% slide do %>
  <ul>
    <li>
      First element
    </li>

    <% element tag: :li do %>
      Second element
    <% end %>

    <li class="prez-element">
      Third element
    </li>
  </ul>
<% end %>
```

Note that all elements are always hidden when a slide first appears.
Any content you want displayed should not be contained in an element.

### Slide horizontal alignment

By default, slides are center aligned.  To left or right align, you
may provide it as an option to the <code>slide</code> method:

```erb
<% slide align: :right do %>
  ...
<% end %>

<% slide align: :left do %>
  ...
<% end %>
```

### Presentation timing

```erb
<% duration 300 %>
```

You can indicate how much time your presentation should take using the
<code>duration</code> helper.  It accepts either the number of seconds
for the total presentation, or a string representation of the form
hours:minutes:seconds.  For example, <code>"2:30:00"</code> would
represent 2 hours and 30 minutes.

Before you start your presentation, you can adjust the amount for the
current run.  During your presentation, the time will be displayed in
the upper left corner.  If you are running low on time, the remaining
time will turn red and flash.  Once you are over, the time will stay
solid red and start to count up.

### Slide timing

Each slide will have a time limit based on the total duration provided
in the upper right corner.  It is simply the total time remaining
divided by the remaining slides, ignoring slides that have specific
timing specified.

Specific timing can be provided to a slide via the
<code>duration</code> option in the slide method.  It accepts the
amount of seconds as a number.

```erb
<% slide duration: 15 do %>
  ...
<% end %>
```

Like the total duration, the slide duration will begin to flash red
when it is running out, and it will stay solid red and count up when
you are over.

### Include custom JS or CSS

```erb
<html>
  <head>
    <%= javascript "myCustomScript" %>
    <%= stylesheet "myCustomStyle" %>
```

CoffeeScript and Sass are supported.  If the file is first found in
the current directory, searching will stop.  The next path will be the
<code>javascripts</code> or <code>stylsheets</code> directory from
within the current directory depending on which asset you are
including.  If all those fail, the file will be searched within the
prez gem itself.  An error will be thrown if the asset cannot be
found.

You can specify the full file name directly, or let the helper find it
for you.  For JavaScript, the extensions searched will be (in this
order): <code>.js.coffee</code>, <code>.coffee</code> and
<code>.js</code>.  For stylesheets, the extensions will be:
<code>.css.scss</code>, <code>.scss</code> and <code>.css</code>.

These assets will be minified before inserting them in the resulting
HTML file.

### Include images

```erb
<% slide do %>
  <p>
    <%= image "myImage" %>
    <%= image "otherImage.png", width: "50%" %>
    <%= image "yetAnotherImage.gif", height: "50%" %>
  </p>
<% end %>
```

Like JS and CSS assets, the images will be searched from the current
directory, then the <code>images</code> directory from within the
current directory.  Also, the extension is optional and can be one of:
<code>.gif</code>, <code>.jpeg</code>, <code>.jpg</code>,
<code>.png</code>, <code>.svg</code>, <code>.tif</code> or
<code>.tiff</code>.

A <code>width</code> and <code>height</code> option are allowed, which
will add the respective attribute to the resulting <code>img</code>
tag.

## Contributing

1. Fork it ( https://github.com/mikestone/prez/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
