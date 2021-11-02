#include "cube_state.h"

#include "cube_coordinate.h"
#include "cube_state.h"
#include "utils.h"

static ID reverse;

typedef struct {
  long cube_size;
  size_t length;
  VALUE coordinates;
  size_t* indices;
} StickerCycleData;

extern const rb_data_type_t StickerCycleData_type;

#define GetStickerCycleData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), StickerCycleData, &StickerCycleData_type, (data)); \
  } while (0)

#define GetInitializedStickerCycleData(obj, data)  \
  do { \
    GetStickerCycleData((obj), (data)); \
    if (data->indices == NULL) { \
      rb_raise(rb_eArgError, "Sticker cycle isn't initialized."); \
    } \
  } while(0)

static VALUE StickerCycleClass = Qnil;

static void StickerCycleData_mark(void* const ptr) {
  const StickerCycleData* data = ptr;
  rb_gc_mark(data->coordinates);
}

static void StickerCycleData_free(void* const ptr) {
  const StickerCycleData* const data = ptr;
  free(data->indices);
  free(ptr);
}

static size_t StickerCycleData_size(const void* const ptr) {
  const StickerCycleData* const data = ptr;
  return sizeof(StickerCycleData) + num_stickers(data->cube_size) * sizeof(VALUE);
}

const rb_data_type_t StickerCycleData_type = {
  "TwistyPuzzles::Native::StickerCycleData",
  {StickerCycleData_mark, StickerCycleData_free, StickerCycleData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY  
};

static VALUE* malloc_indices(const size_t n) {
  VALUE* const indices = malloc(n * sizeof(size_t));
  if (indices == NULL) {
    rb_raise(rb_eNoMemError, "Allocating sticker cycle failed.");
  }
  return indices;
}

static VALUE StickerCycle_alloc(const VALUE klass) {
  StickerCycleData* data;
  const VALUE object = TypedData_Make_Struct(klass, StickerCycleData, &StickerCycleData_type, data);
  data->cube_size = 0;
  data->length = 0;
  data->coordinates = Qnil;
  data->indices = NULL;
  return object;
}

static VALUE StickerCycle_initialize(const VALUE self, const VALUE cube_size, const VALUE coordinates) {
  Check_Type(cube_size, T_FIXNUM);
  Check_Type(coordinates, T_ARRAY);
  const long checked_cube_size = FIX2INT(cube_size);
  check_cube_size(checked_cube_size);
  const size_t n = RARRAY_LEN(coordinates);
  StickerCycleData* data;
  GetStickerCycleData(self, data);
  data->cube_size = checked_cube_size;
  data->length = n;
  data->coordinates = coordinates;
  data->indices = malloc_indices(data->length);
  for (size_t i = 0; i < n; ++i) {
    const VALUE coordinate = rb_ary_entry(coordinates, i);
    data->indices[i] = CubeCoordinate_sticker_index(coordinate, checked_cube_size);
  }
  return self;
}

static VALUE StickerCycle_apply_to(const VALUE self, const VALUE cube_state) {
  const StickerCycleData* sticker_cycle_data;
  GetInitializedStickerCycleData(self, sticker_cycle_data);
  const CubeStateData* cube_state_data;
  GetInitializedCubeStateData(cube_state, cube_state_data);

  if (cube_state_data->cube_size != sticker_cycle_data->cube_size) {
    rb_raise(rb_eArgError, "Cube size of sticker cycle must equal cube size of cube state. Got %ld vs %ld.", sticker_cycle_data->cube_size, cube_state_data->cube_size);
  }
  apply_sticker_cycle(cube_state_data->stickers, sticker_cycle_data->indices, sticker_cycle_data->length, false);
  return Qnil;
}

static VALUE StickerCycle_hash(const VALUE self) {
  const StickerCycleData* data;
  GetInitializedStickerCycleData(self, data);

  st_index_t hash = rb_hash_start((st_index_t)StickerCycle_hash);
  hash = rb_hash_uint(hash, data->length);
  hash = rb_hash_uint(hash, data->cube_size);
  const size_t n = data->length;
  for (size_t i = 0; i < n; ++i) {
    hash = rb_hash_uint(hash, data->indices[i]);
  }
  return ST2FIX(rb_hash_end(hash));
}

static VALUE StickerCycle_eql(const VALUE self, const VALUE other) {
  if (self == other) {
    return Qtrue;
  }
  if (rb_obj_class(self) != rb_obj_class(other)) {
    return Qfalse;
  }
  const StickerCycleData* self_data;
  GetInitializedStickerCycleData(self, self_data);
  const StickerCycleData* other_data;
  GetInitializedStickerCycleData(other, other_data);
  if (self_data->cube_size != other_data->cube_size) {
    return Qfalse;
  }
  if (self_data->length != other_data->length) {
    return Qfalse;
  }
  const size_t n = self_data->length;
  for (size_t i = 0; i < n; ++i) {
    if (self_data->indices[i] != other_data->indices[i]) {
      return Qfalse;
    }
  }
  return Qtrue;
}

static VALUE StickerCycle_cube_size(const VALUE self) {
  const StickerCycleData* data;
  GetInitializedStickerCycleData(self, data);
  return ST2FIX(data->cube_size);
}

static VALUE StickerCycle_length(const VALUE self) {
  const StickerCycleData* data;
  GetInitializedStickerCycleData(self, data);
  return ST2FIX(data->length);
}

static VALUE StickerCycle_coordinates(const VALUE self) {
  const StickerCycleData* data;
  GetInitializedStickerCycleData(self, data);
  return data->coordinates;
}

static VALUE StickerCycle_inverse(const VALUE self) {
  const StickerCycleData* data;
  GetInitializedStickerCycleData(self, data);
  const long n = data->length;
  StickerCycleData* inverse_data;
  const VALUE inverse = TypedData_Make_Struct(rb_obj_class(self), StickerCycleData, &StickerCycleData_type, inverse_data);
  inverse_data->cube_size = data->cube_size;
  inverse_data->length = n;
  inverse_data->indices = malloc_indices(n);
  inverse_data->coordinates = rb_funcall(data->coordinates, reverse, 0);
  for (int i = 0; i < n; ++i) {
    inverse_data->indices[i] = data->indices[n - 1 - i];
  }
  return inverse;
}

void init_sticker_cycle_class_under(const VALUE module) {
  reverse = rb_intern("reverse");
  StickerCycleClass = rb_define_class_under(module, "StickerCycle", rb_cObject);
  rb_define_alloc_func(StickerCycleClass, StickerCycle_alloc);
  rb_define_method(StickerCycleClass, "initialize", StickerCycle_initialize, 2);
  rb_define_method(StickerCycleClass, "apply_to", StickerCycle_apply_to, 1);
  rb_define_method(StickerCycleClass, "hash", StickerCycle_hash, 0);
  rb_define_method(StickerCycleClass, "eql?", StickerCycle_eql, 1);
  rb_define_alias(StickerCycleClass, "==", "eql?");
  rb_define_method(StickerCycleClass, "cube_size", StickerCycle_cube_size, 0);
  rb_define_method(StickerCycleClass, "length", StickerCycle_length, 0);
  rb_define_method(StickerCycleClass, "coordinates", StickerCycle_coordinates, 0);
  rb_define_method(StickerCycleClass, "inverse", StickerCycle_inverse, 0);
}
