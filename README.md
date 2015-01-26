## Sixtysix

A wrapper arround `page.js` to provide `KDRouter`-like API.

## Example

```coffee
{ Router } = require 'sixtysix'

router = new Router

router.addRoute '/user/:id', ({ params }) ->

  { id } = params
  console.log id

router.listen()

router.handleRoute '/user/3'
# => 3

```

## Installation

```
npm install sixtysix
```

