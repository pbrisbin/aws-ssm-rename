> [!NOTE]
> All of my GitHub repositories have been **archived** and will be migrated to
> Codeberg as I next work on them. This repository either now lives, or will
> live, at:
>
> https://codeberg.org/pbrisbin/aws-ssm-rename
>
> If you need to report an Issue or raise a PR, and this migration hasn't
> happened yet, send an email to me@pbrisbin.com.

# aws-ssm-rename

Like `rename(1)` but for AWS SSM Parameters.

## Usage

```console
% aws-ssm-rename --help

Usage:
  aws-ssm-rename [options] <expression> <replacement> <parameter>...

Rename AWS SSM parameters.

Options:
 -v, --verbose          explain what is being done
 -n, --no-act           do not make any changes
 -a, --all              replace all ocurrences
 -o, --no-overwrite     don't overwrite existing parameters
 -i, --interactive      prompt before overwrite
 -g, --no-glob          don't match parameters as globs

 -h, --help             display this help
 -V, --version          display version


rename(1) features not implemented:
 -s, --symlink
 -l, --last

For more details see aws-ssm-rename(1).
```

Documentation is also available [in-repository](./man/aws-ssm-rename.1.ronn).

## Installation

### Released

```console
version=v0.0.0 # or whatever
curl -L "https://github.com/pbrisbin/aws-ssm-rename/releases/download/$version/aws-ssm-rename.tar.gz" | tar xzvf -
cd aws-ssm-rename
```

For user-local, run:

```console
make install PREFIX=$HOME/.local
```

For system-wide, run:

```console
sudo make install
```

### Development

Into `$HOME/.local/bin`:

```console
git clone https://github.com/pbrisbin/aws-ssm-rename
cd aws-ssm-rename
make install.check
```

## TODO

- [ ] Consider an actual programming language
- [ ] Implement completions
- [x] Add tests

## LICENSE

This project is licensed AGPLv3. See [COPYING](./COPYING).

---

[CHANGELOG](./CHANGELOG.md)
