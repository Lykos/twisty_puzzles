#pragma once

#include <ruby.h>

#include "face_symbols.h"
#include "utils.h"

size_t num_stickers(long cube_size);

typedef struct {
  size_t x;
  size_t y;
} Point;

size_t sticker_index(long cube_size, face_index_t on_face_index, Point point);

long transform_index(face_index_t index_base_face_index, long cube_size, long index);

bool switch_axes(face_index_t x_base_face_index, face_index_t y_base_face_index);

void check_base_face_indices(face_index_t on_face_index,
                             face_index_t x_base_face_index,
                             face_index_t y_base_face_index);

Point point_on_face(face_index_t on_face_index,
                    face_index_t x_base_face_index,
                    face_index_t y_base_face_index,
                    long cube_size,
                    long untransformed_x,
                    long untransformed_y);

size_t CubeCoordinate_sticker_index(VALUE self, long cube_size);

void init_cube_coordinate_class_under(VALUE module);
