# Contributing to Vutuv

The aim of this document is to help developers contribute to this project.

This document is a work-in-progress. If you feel that you can improve it,
please open an issue and let us know.

## Setup

1. Make sure you have the following programs installed:

    * Erlang > 21.1
    * Elixir > 1.8
    * nodejs > 6.8.0
    * postgresql

1. [Fork](https://help.github.com/articles/fork-a-repo/) the project, clone your fork,
and configure the remotes.

1. Create and migrate your database with `mix ecto.setup`

1. Install [pre-commit](https://pre-commit.com/) and run `pre-commit install`
in the root directory of the project.

## Tooling

We use the following tools in our development process.

### Pre-commit

After running `pre-commit install`, several pre-commit git hooks will be
added. These hooks perform certain checks when making a commit, and the
commit will not be made if any of these checks fail.

The configured checks are:

* tests check using `mix test`
* format check using `mix format --check-formatted`
* compilation using `mix compile --warnings-as-errors`
* trailing whitespace check
* merge conflict check
* yaml file check
* end of each file ends in a newline check
* a check that you are not committing to the master, staging or production branch

If the end-of-file-fixer fails, run the commit again and it should pass
the second time.

### Dialyzer

Dialyzer can be used to analyze the Elixir code, especially for type errors.
We can use it through [dialyxir](https://github.com/jeremyjh/dialyxir), which
is installed as a dev dependency.

To run dialyzer, run `mix dialyzer`.

### Custom generators

We are using custom templates for context and schema generation (when
using the Phoenix `phx.gen.*` generators).

See the [Custom generator wiki page](https://github.com/vutuv/vutuv/wiki/Custom-generators)
for help using the Phoenix generators with these templates.

## Pull requests

We recommend that you follow this guide, which is based on the
[Phoenix contributing guide](https://github.com/phoenixframework/phoenix/blob/master/CONTRIBUTING.md).

1. Choose an issue you want to work on and assign yourself to it.
(If a relevant issue does not exist yet, open the issue first and then assign
yourself to it).

1. Create a new topic branch (off of `master`) to work on the issue.

    **IMPORTANT**: making changes in `master` is discouraged. You should always
    keep your local `master` in sync with upstream `master` and make your
    changes in topic branches.

    ```bash
    git checkout -b <topic-branch-name>
    ```

1. As you work on the issue, commit your changes in logical chunks.

1. Push your topic branch up to your fork:

    ```bash
    git push origin <topic-branch-name>
    ```

1. [Open a Pull Request](https://help.github.com/articles/about-pull-requests/)
with the following information (this should help the reviewer understand the
pull request better):

    * a clear, and informative, title
    * a description that references the issue(s) you have been working on
      * do not leave the description blank

1. Make sure that your topic branch is up-to-date. If necessary, rebase
on master and resolve any conflicts.

    **IMPORTANT**: _Never ever_ merge upstream `master` into your branches. You
    should always `git rebase` on `master` to bring your changes up to date when
    necessary.

    ```bash
    git checkout master
    git pull upstream master
    git checkout <your-topic-branch>
    git rebase master
    ```

## Configure your SMTP setup

The system uses the [Bamboo](https://github.com/thoughtbot/bamboo) email
library by [thoughtbot](https://thoughtbot.com/) to send emails via SMTP.

### Development

In the development environment emails are not sent to an actual SMTP
server but displayed in the browser via [Bamboo.EmailPreviewPlug](https://hexdocs.pm/bamboo/Bamboo.EmailPreviewPlug.html). To see which emails have been sent, visit [http://localhost:4000/sent_emails](http://localhost:4000/sent_emails)
