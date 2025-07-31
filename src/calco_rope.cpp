#include "calco_rope.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;
using namespace calco_rope_sim;

void CalcoRope::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_line_path"), &CalcoRope::get_line_path);
    ClassDB::bind_method(D_METHOD("set_line_path", "path"), &CalcoRope::set_line_path);
    ClassDB::bind_method(D_METHOD("get_shape_cast_path"), &CalcoRope::get_shape_cast_path);
    ClassDB::bind_method(D_METHOD("set_shape_cast_path", "path"), &CalcoRope::set_shape_cast_path);
	ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "line_path", PROPERTY_HINT_NODE_PATH_VALID_TYPES, "Line2D"), "set_line_path", "get_line_path");
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "shape_cast_path", PROPERTY_HINT_NODE_PATH_VALID_TYPES, "ShapeCast2D"), "set_shape_cast_path", "get_shape_cast_path");   

    ClassDB::bind_method(D_METHOD("get_total_rope_distance"), &CalcoRope::get_total_rope_distance);
    ClassDB::bind_method(D_METHOD("get_segment_length"), &CalcoRope::get_segment_length);
    ClassDB::bind_method(D_METHOD("set_point", "index", "position"), &CalcoRope::set_point);
    ClassDB::bind_method(D_METHOD("get_point", "index"), &CalcoRope::get_point);

    ClassDB::bind_method(D_METHOD("get_gravity"), &CalcoRope::get_gravity);
    ClassDB::bind_method(D_METHOD("set_gravity", "gravity"), &CalcoRope::set_gravity);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2, "gravity"), "set_gravity", "get_gravity");

    ClassDB::bind_method(D_METHOD("get_damp_factor"), &CalcoRope::get_damp_factor);
    ClassDB::bind_method(D_METHOD("set_damp_factor", "damp_factor"), &CalcoRope::set_damp_factor);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "damp_factor", PROPERTY_HINT_RANGE, "0.0,1.0,0.01"), "set_damp_factor", "get_damp_factor");

    ClassDB::bind_method(D_METHOD("get_constraint_run_count"), &CalcoRope::get_constraint_run_count);
    ClassDB::bind_method(D_METHOD("set_constraint_run_count", "constraint_run_count"), &CalcoRope::set_constraint_run_count);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "constraint_run_count", PROPERTY_HINT_RANGE, "1,100,1"), "set_constraint_run_count", "get_constraint_run_count");

    ClassDB::bind_method(D_METHOD("get_collision_run_interval"), &CalcoRope::get_collision_run_interval);
    ClassDB::bind_method(D_METHOD("set_collision_run_interval", "collision_run_interval"), &CalcoRope::set_collision_run_interval);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "collision_run_interval", PROPERTY_HINT_RANGE, "1,20,1"), "set_collision_run_interval", "get_collision_run_interval");

    ClassDB::bind_method(D_METHOD("get_collision_radius"), &CalcoRope::get_collision_radius);
    ClassDB::bind_method(D_METHOD("set_collision_radius", "collision_radius"), &CalcoRope::set_collision_radius);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "collision_radius", PROPERTY_HINT_RANGE, "0.1,10.0,0.1"), "set_collision_radius", "get_collision_radius");

    ClassDB::bind_method(D_METHOD("get_bounce_factor"), &CalcoRope::get_bounce_factor);
    ClassDB::bind_method(D_METHOD("set_bounce_factor", "bounce_factor"), &CalcoRope::set_bounce_factor);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "bounce_factor", PROPERTY_HINT_RANGE, "0.0,1.0,0.01"), "set_bounce_factor", "get_bounce_factor");

	ClassDB::bind_method(D_METHOD("get_point_count"), &CalcoRope::get_point_count);
    ClassDB::bind_method(D_METHOD("set_point_count", "point_count"), &CalcoRope::set_point_count);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "point_count", PROPERTY_HINT_RANGE, "2,100,1"), "set_point_count", "get_point_count");

    ClassDB::bind_method(D_METHOD("get_length"), &CalcoRope::get_length);
    ClassDB::bind_method(D_METHOD("set_length", "length"), &CalcoRope::set_length);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "length", PROPERTY_HINT_RANGE, "1.0,1000.0,0.1"), "set_length", "get_length");

    ClassDB::bind_method(D_METHOD("get_origin"), &CalcoRope::get_origin);
    ClassDB::bind_method(D_METHOD("set_origin", "origin"), &CalcoRope::set_origin);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2, "origin"), "set_origin", "get_origin");
}

CalcoRope::CalcoRope() {
    _point_count = 30;
    _length = 50.0f;
    _gravity = Vector2(0.0f, 9.8f);
    _damp_factor = 0.98f;
    _constraint_run_count = 50;
    _collision_run_interval = 5;
    _collision_radius = 1.0f;
    _bounce_factor = 0.1f;
    _total_rope_distance = 0.0f;
}

CalcoRope::~CalcoRope() {
}

void CalcoRope::_ready() {
    if (!_line_path.is_empty()) {
        _line = get_node<Line2D>(_line_path);
    }
    if (!_shape_cast_path.is_empty()) {
        _shape_cast = get_node<ShapeCast2D>(_shape_cast_path);
    }

	_origin = get_global_position();

	_points.resize(_point_count);
	_line->clear_points();
	for (int i = 0; i < _point_count; ++i) {
		Vector2 pos = _origin + Vector2(0, 1) * (i + get_segment_length());
		_points[i] = RopePoint(pos);
		_line->add_point(pos);
	}

	render_simulation(1.0 / 60.0);
}

void CalcoRope::_process(double delta) {
	render_simulation(delta);
}

void CalcoRope::_physics_process(double delta) {
	update_simulation(delta);
}

void CalcoRope::render_simulation(double delta) {
	for (int i = 0; i < _point_count; ++i) {
		_line->set_point_position(i, _points[i].pos);
	}
}

void CalcoRope::update_simulation(double delta) {
    // Fix the first point
    _points[0].pos = _origin;
    _points[0].prev_pos = _origin;

    // Update positions with velocity and gravity
    for (int i = 0; i < _point_count; ++i) {
        RopePoint& point = _points[i];
        Vector2 vel = (point.pos - point.prev_pos) * _damp_factor;
        point.prev_pos = point.pos;
        point.pos += vel;
        point.pos += _gravity * static_cast<float>(delta);
    }

    // Apply constraints
    for (int ic = 0; ic < _constraint_run_count; ++ic) {
        Vector2 point_diff = _points[0].pos - _points[1].pos;
        float diff = point_diff.length() - get_segment_length();
        Vector2 change = point_diff.normalized() * diff;
        _points[1].pos += change;

        for (int i = 0; i < _point_count - 2; ++i) {
            point_diff = _points[i + 1].pos - _points[i + 2].pos;
            diff = point_diff.length() - get_segment_length();
            change = point_diff.normalized() * diff * 0.5f;
            _points[i + 1].pos -= change;
            _points[i + 2].pos += change;
        }

        if (ic % _collision_run_interval == 0) {
            for (RopePoint& point : _points) {
                Vector2 vel = point.pos - point.prev_pos;
				_shape_cast->set_global_position(point.pos);
				_shape_cast->force_shapecast_update();

				Array collision_results = _shape_cast->get_collision_result();
                for (int j = 0; j < collision_results.size(); ++j) {
                    Dictionary coll_info = collision_results[j];
                    Vector2 closest_point = coll_info["point"];
                    float distance = point.pos.distance_to(closest_point);
                    if (distance < _collision_radius) {
                        Vector2 normal = coll_info["normal"];
                        if (normal == Vector2(0, 0)) {
                            normal = (point.pos - closest_point).normalized();
                        }
                        float depth = _collision_radius - distance;
                        point.pos += normal * depth;

                        Vector2 b = vel.bounce(normal) * _bounce_factor;
                        vel = b;
                    }
                }
                point.prev_pos = point.pos - vel;
            }
        }
    }

    _total_rope_distance = 0.0f;
    for (int i = 0; i < _point_count - 1; ++i) {
        _total_rope_distance += _points[i].pos.distance_to(_points[i + 1].pos);
    }
}

NodePath CalcoRope::get_line_path() const {
    return _line_path;
}

void CalcoRope::set_line_path(const NodePath& path) {
    _line_path = path;
    if (is_inside_tree()) {
        _line = get_node<Line2D>(_line_path);
    }
}

NodePath CalcoRope::get_shape_cast_path() const {
    return _shape_cast_path;
}

void CalcoRope::set_shape_cast_path(const NodePath& path) {
    _shape_cast_path = path;
    if (is_inside_tree()) {
        _shape_cast = get_node<ShapeCast2D>(_shape_cast_path);
    }
}

float CalcoRope::get_total_rope_distance() const {
	return _total_rope_distance;
}
float CalcoRope::get_segment_length() const {
	return _length / _point_count;
}

void CalcoRope::set_point(const int index, const Vector2 position) {
	_points[index].pos = position;
}
Vector2 CalcoRope::get_point(const int index) const {
	return _points[index].pos;
}

int CalcoRope::get_point_count() const {
	return _point_count;
}

void CalcoRope::set_point_count(const int point_count) {
	_point_count = point_count;
}

float CalcoRope::get_length() const {
    return _length;
}

void CalcoRope::set_length(const float length) {
	_length = length;
}

// Getters and setters for new properties
Vector2 CalcoRope::get_gravity() const {
    return _gravity;
}

void CalcoRope::set_gravity(const Vector2 gravity) {
    _gravity = gravity;
}

float CalcoRope::get_damp_factor() const {
    return _damp_factor;
}

void CalcoRope::set_damp_factor(const float damp_factor) {
    _damp_factor = damp_factor;
}

int CalcoRope::get_constraint_run_count() const {
    return _constraint_run_count;
}

void CalcoRope::set_constraint_run_count(const int constraint_run_count) {
    _constraint_run_count = constraint_run_count;
}

int CalcoRope::get_collision_run_interval() const {
    return _collision_run_interval;
}

void CalcoRope::set_collision_run_interval(const int collision_run_interval) {
    _collision_run_interval = collision_run_interval;
}

float CalcoRope::get_collision_radius() const {
    return _collision_radius;
}

void CalcoRope::set_collision_radius(const float collision_radius) {
    _collision_radius = collision_radius;
}

float CalcoRope::get_bounce_factor() const {
    return _bounce_factor;
}

void CalcoRope::set_bounce_factor(const float bounce_factor) {
    _bounce_factor = bounce_factor;
}

Vector2 CalcoRope::get_origin() const {
    return _origin;
}

void CalcoRope::set_origin(const Vector2 origin) {
    _origin = origin;
}