# DNote

* [Homepage](http://rubyworks.github.com/dnote)
* [Mailing List](http://googlegroups.com/group/rubyworks-mailinglist)
* [Source Code](http://github.com/rubyworks/dnote)

[![Gem Version](https://badge.fury.io/rb/mvz-dnote.svg)](https://badge.fury.io/rb/mvz-dnote)
[![Build Status](https://travis-ci.org/mvz/dnote.svg?branch=master)](https://travis-ci.org/mvz/dnote)
[![Coverage Status](https://coveralls.io/repos/github/mvz/mvz-dnote/badge.svg?branch=master)](https://coveralls.io/github/mvz/mvz-dnote?branch=master)
[![Dependency Status](https://gemnasium.com/badges/github.com/mvz/mvz-dnote.svg)](https://gemnasium.com/github.com/mvz/mvz-dnote)
[![Maintainability](https://api.codeclimate.com/v1/badges/608621bbad5de3a98e3b/maintainability)](https://codeclimate.com/github/mvz/dnote/maintainability)

## DESCRIPTION

Extract development notes from source code and generate some nice
output formats for them.


## SYNOPSIS

### Note Structure

DNote scans for the common note patterns used by developers of many languages in the form of an
all-caps labels followed by a colon. To be more specific, for DNote to recognize a note,
it needs to follow this simple set of rules:

1. Notes start with an all-caps label punctuated with a colon, followed by the note's text.

        # LABEL: description ...

2. Any note that requires more than one line must remain flush to the left
margin (the margin is set by the first line). This is done because RDoc will mistake
the note for a `pre` block if it is indented.

        # LABEL: description ...
        # continue ...

3. An alternative to the previous limitation is to indent the whole note, making it
a `<pre>` block when rendered by RDoc. Then the text layout is free-form.

        # This is a description of something...
        #
        #   LABEL: description ...
        #          continue ...

That's all there is to it, if I can convince the developers of RDoc to recognize labels,
we may eventually be able to relax the flush rule too, which would be very nice.

There is also a command-line option, `--no-colon`, which deactives the need for
a colon after the note label. However this often produces false positives, so its use is
discouraged.

### Generating Notes

As you can see the commandline interface is pretty straight-forward.

    USAGE:

      dnote [OPTIONS] path1 [path2 ...]

    OUTPUT FORMAT: (choose one)
        -f, --format NAME                select a format [text]
        -c, --custom FILE                use a custom ERB template
            --file                       shortcut for text/file format
            --list                       shortcut for text/list format

    OTHER OPTIONS:
        -l, --label LABEL                labels to collect
            --[no-]colon                 match labels with/without colon suffix
        -m, --marker MARK                alternative remark marker
        -u  --url TEMPLATE               url template for line entries (for HTML)
        -x, --exclude PATH               exclude file or directory
        -i, --ignore NAME                ignore based on any part of the pathname
        -t, --title TITLE                title to use in header
        -o, --output PATH                name of file or directory
        -n, --dryrun                     do not actually write to disk
            --debug                      debug mode

    COMMAND OPTIONS:
        -T, --templates                  list available format templates
        -h, --help                       show this help information

The default path is `**/*.rb` and the default format is `-f text`.
Here is an example of DNote's current notes in RDoc format:

    = Development Notes

    == TODO

    === file://lib/dnote/notes.rb

    * TODO: Add ability to read header notes. They often
    have a outline format, rather then the single line. (19)
    * TODO: Need good CSS file. (22)
    * TODO: Need XSL? (24)

    === file://plug/syckle/services/dnote.rb

    * TODO: Should this service be part of the +site+ cycle? (18)

    (4 TODOs)


## INSTALLATION

The usual rubygems command will do the trick.

    $ gem install dnote


## COPYRIGHT

Copyright (c) 2006 Thomas Sawyer, Rubyworks

Copyright (c) 2017-2018 Matijs van Zuijlen

DNote is distributable in accordance with the terms of the *FreeBSD* license.

See COPYING.rdoc for details.
