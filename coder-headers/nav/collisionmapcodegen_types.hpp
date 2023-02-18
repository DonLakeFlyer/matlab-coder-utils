/* Copyright 2022 The MathWorks, Inc. */

#ifndef COLLISIONMAPCODEGEN_TYPES_HPP_
#define COLLISIONMAPCODEGEN_TYPES_HPP_

// For use of std::numeric_limits<T>::infinity()
#include <limits>

// Unsigned integer type used to represent tree depth in CollisionMap
typedef unsigned int depth_t;

namespace nav {
// Representation of inf for given numeric type
template <typename T>
constexpr T INF = std::numeric_limits<T>::infinity();

constexpr depth_t MAX_TREE_DEPTH = 16u;
} // namespace nav

#endif /* COLLISIONMAPCODEGEN_TYPES_HPP_ */
