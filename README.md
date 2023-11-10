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

TODO

### Development

Into `$HOME/.local/bin`:

```console
git clone https://github.com/pbrisbin/aws-ssm-rename
cd aws-ssm-rename
make install.check
```

## TODO

- [ ] Add examples to docs
- [ ] Consider an actual programming language
- [ ] Implement completions
- [ ] Add tests

---

[CHANGELOG](./CHANGELOG.md) | [LICENSE](./LICENSE)
