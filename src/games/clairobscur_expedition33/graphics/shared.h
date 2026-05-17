#ifndef SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_SHARED_H_
#define SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_SHARED_H_

// Shim: graphics-bundle shaders historically lived in their own addon and
// did `#include "../shared.h"`. After being merged into the host HDR addon,
// the canonical struct + accessors live in the host's `shared.h` one
// directory up. Forward to it.
#include "../shared.h"

#endif  // SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_SHARED_H_
