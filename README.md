# `license-prepender` - Prepend License Boilerplates

A program that handles the license burocracy with a simple bash command. This program prepends a license boilerplate into all of your repository files and generates a `LICENSE` file at the repository root path. It prepends all files that match the extensions supported in [Supported Extensions](#supported-extensions) and will only work with licenses provided in [Supported Licenses](#supported-licenses).

## Usage
`./license-prepender <REPO_PATH> <LICENSE_NAME> <YEAR> <AUTHOR>`

## Supported Extensions
- **Go** (.go)
- **Java** (.java)
- **Javascript** (.js)
- **Kotlin** (.kt)
- **Rust** (.rs)
- **Typescript** (.ts)
- **XML** (.xml)

## Supported Licenses
- [GNU Affero General Public License v3.0 or later](https://spdx.org/licenses/AGPL-3.0-or-later.html) (agplv3)
- [GNU General Public License v3.0 or later](https://spdx.org/licenses/GPL-3.0-or-later.html) (gplv3)
- [GNU Lesser General Public License v3.0 or later](https://spdx.org/licenses/LGPL-3.0-or-later.html) (lgplv3)
- [Mozilla Public License 2.0](https://spdx.org/licenses/MPL-2.0.html) (mozilla2)
- [Apache 2.0](https://spdx.org/licenses/Apache-2.0.html) (apache2)
- [MIT License](https://spdx.org/licenses/MIT.html) (mit)
- [Boost Software License 1.0](https://spdx.org/licenses/BSL-1.0.html) (boost1)
- [The Unlicense](https://spdx.org/licenses/Unlicense.html) (unlicense)
