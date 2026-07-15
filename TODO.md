# TODO

## Now

## Later

## Never

## Done
- [x] Fix OPML folder tracking (folder context now scoped via an outline stack:
      cleared on `didEndElement`, so sibling folders, nested folders, and
      top-level feeds after a folder are labeled correctly)
- [x] Add integration tests for the DB query layer (fixture DB matching NNW's
      schema) plus OPML edge cases, limit clamping, and account resolution
- [x] Clamp `limit` arguments (reject negative/zero/oversized values)
- [x] Build against Swift 6.3 toolchain (bumped swift-sdk to 0.12.1)
