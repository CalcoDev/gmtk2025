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
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "damp_factor"), "set_damp_factor", "get_damp_factor");

    ClassDB::bind_method(D_METHOD("get_constraint_run_count"), &CalcoRope::get_constraint_run_count);
    ClassDB::bind_method(D_METHOD("set_constraint_run_count", "constraint_run_count"), &CalcoRope::set_constraint_run_count);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "constraint_run_count"), "set_constraint_run_count", "get_constraint_run_count");

    ClassDB::bind_method(D_METHOD("get_collision_run_interval"), &CalcoRope::get_collision_run_interval);
    ClassDB::bind_method(D_METHOD("set_collision_run_interval", "collision_run_interval"), &CalcoRope::set_collision_run_interval);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "collision_run_interval"), "set_collision_run_interval", "get_collision_run_interval");

    ClassDB::bind_method(D_METHOD("get_collision_radius"), &CalcoRope::get_collision_radius);
    ClassDB::bind_method(D_METHOD("set_collision_radius", "collision_radius"), &CalcoRope::set_collision_radius);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "collision_radius"), "set_collision_radius", "get_collision_radius");

    ClassDB::bind_method(D_METHOD("get_bounce_factor"), &CalcoRope::get_bounce_factor);
    ClassDB::bind_method(D_METHOD("set_bounce_factor", "bounce_factor"), &CalcoRope::set_bounce_factor);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "bounce_factor"), "set_bounce_factor", "get_bounce_factor");

    ClassDB::bind_method(D_METHOD("get_lasso_enabled"), &CalcoRope::get_lasso_enabled);
    ClassDB::bind_method(D_METHOD("set_lasso_enabled", "lasso_enabled"), &CalcoRope::set_lasso_enabled);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "lasso_enabled"), "set_lasso_enabled", "get_lasso_enabled");

    ClassDB::bind_method(D_METHOD("get_lasso_diameter"), &CalcoRope::get_lasso_diameter);
    ClassDB::bind_method(D_METHOD("set_lasso_diameter", "lasso_diameter"), &CalcoRope::set_lasso_diameter);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "lasso_diameter"), "set_lasso_diameter", "get_lasso_diameter");

	ClassDB::bind_method(D_METHOD("get_point_count"), &CalcoRope::get_point_count);
    ClassDB::bind_method(D_METHOD("set_point_count", "point_count"), &CalcoRope::set_point_count);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "point_count"), "set_point_count", "get_point_count");

    ClassDB::bind_method(D_METHOD("get_length"), &CalcoRope::get_length);
    ClassDB::bind_method(D_METHOD("set_length", "length"), &CalcoRope::set_length);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "length"), "set_length", "get_length");

    ClassDB::bind_method(D_METHOD("get_origin"), &CalcoRope::get_origin);
    ClassDB::bind_method(D_METHOD("set_origin", "origin"), &CalcoRope::set_origin);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2, "origin"), "set_origin", "get_origin");

    ClassDB::bind_method(D_METHOD("print_spatial_hash", "top_left", "top_right"), &CalcoRope::print_spatial_hash);
    ClassDB::bind_method(D_METHOD("update_spatial_hash", "top_left", "top_right"), &CalcoRope::update_spatial_hash);
    ClassDB::bind_method(D_METHOD("update_simulation", "render"), &CalcoRope::update_simulation);
    ClassDB::bind_method(D_METHOD("render_simulation", "render"), &CalcoRope::render_simulation);
    
    ClassDB::bind_method(D_METHOD("clear_spatial_hash_dyanmic"), &CalcoRope::clear_spatial_hash_dyanmic);
    ClassDB::bind_method(D_METHOD("update_spatial_hash_dynamic_obb", "center", "half_size", "theta"), &CalcoRope::update_spatial_hash_dynamic_obb);
    ClassDB::bind_method(D_METHOD("update_spatial_hash_dynamic_circle", "center", "radius"), &CalcoRope::update_spatial_hash_dynamic_circle);
    
    ClassDB::bind_method(D_METHOD("get_lasso_circular_force_factor"), &CalcoRope::get_lasso_circular_force_factor);
    ClassDB::bind_method(D_METHOD("set_lasso_circular_force_factor", "lasso_circular_force_factor"), &CalcoRope::set_lasso_circular_force_factor);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "lasso_circular_force_factor"), "set_lasso_circular_force_factor", "get_lasso_circular_force_factor");

    ClassDB::bind_method(D_METHOD("get_lasso_index"), &CalcoRope::get_lasso_index);
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
    _lasso_enabled = false;
    _lasso_diameter = 10.0f;
    _total_rope_distance = 0.0f;
    _lasso_circular_force_factor = 1.0f; // Default value
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

void CalcoRope::update_spatial_hash(Vector2 top_left, Vector2 bottom_right) {
    // double grid_size = (double) get_segment_length();
    Vector2i top_left_cell = top_left / (_collision_radius / 2.0);
    Vector2i bottom_right_cell = bottom_right / (_collision_radius / 2.0);
    // godot::print_line("Starting updating spatial hash global: ", top_left, bottom_right);
    // godot::print_line("Starting updating spatial hash: ", top_left_cell, bottom_right_cell);

    _spatial_hash.clear();
    for (int y = top_left_cell.y; y < bottom_right_cell.y; ++y) {
        for (int x = top_left_cell.x; x < bottom_right_cell.x; ++x) {
            Vector2i global_cell = Vector2i(x, y);
            Vector2 global_position_pos = global_cell * (_collision_radius / 2.0);
            // godot::print_line(global_cell, " ", global_position_pos);
            _shape_cast->set_global_position(global_position_pos);
            _shape_cast->force_shapecast_update();
            Array collision_results = _shape_cast->get_collision_result();
            double min_dist = 9999.9;
            for (int i = 0; i < collision_results.size(); ++i) {
                Dictionary coll_info = collision_results[i];
                Vector2 closest_point = coll_info["point"];
                // godot::print_line("pos: ", global_position_pos, " | col: ", closest_point);
                double distance = global_position_pos.distance_to(closest_point);
                if (distance < min_dist) {
                    v2f v = v2f(closest_point);
                    v2i aa = v2i(global_cell);
                    _spatial_hash[aa] = v;
                    // godot::print_line("set pos: ", aa.x, " ", aa.y, " | ", v.x, " ", v.y);
                    min_dist = distance;
                }
            }
            // if (collision_results.size() == 0) {
            //     _spatial_hash[v2i(global_cell)] = Vector2(0, 0);
            // }
        }
    }
}

void CalcoRope::clear_spatial_hash_dyanmic() {
    _spatial_hash_dynamic.clear();
}

Vector2 rotate_point(const Vector2& point, float theta) {
    float cos_theta = std::cos(theta);
    float sin_theta = std::sin(theta);
    return {
        point.x * cos_theta - point.y * sin_theta,
        point.x * sin_theta + point.y * cos_theta
    };
}

void CalcoRope::update_spatial_hash_dynamic_obb(Vector2 center, Vector2 half_size, double theta) {
    Vector2 local_corners[4] = {
        Vector2(-half_size.x, -half_size.y),
        Vector2(half_size.x, -half_size.y),
        Vector2(half_size.x, half_size.y),
        Vector2(-half_size.x, half_size.y),
    };

    float min_x = std::numeric_limits<float>::max();
    float max_x = std::numeric_limits<float>::lowest();
    float min_y = std::numeric_limits<float>::max();
    float max_y = std::numeric_limits<float>::lowest();

    for (const auto& corner : local_corners) {
        Vector2 rotated = rotate_point(corner, theta);
        Vector2 world_point = center + rotated;
        min_x = std::min(min_x, world_point.x);
        max_x = std::max(max_x, world_point.x);
        min_y = std::min(min_y, world_point.y);
        max_y = std::max(max_y, world_point.y);
    }

    float offset = _collision_radius;
    Vector2i top_left_cell = Vector2(min_x - offset, min_y - offset) / (_collision_radius / 2.0);
    Vector2i bottom_right_cell = Vector2(max_x + offset, max_y + offset) / (_collision_radius / 2.0);
    for (int y = top_left_cell.y - 1; y < bottom_right_cell.y + 1; ++y) {
        for (int x = top_left_cell.x - 1; x < bottom_right_cell.x + 1; ++x) {
            Vector2i global_cell = Vector2i(x, y);
            Vector2 global_pos = global_cell * (_collision_radius / 2.0);

            Vector2 translated = global_pos - center;
            Vector2 local_point = rotate_point(translated, -theta);

            Vector2 closest = rotate_point(Vector2(
                std::max(-half_size.x, std::min(local_point.x, half_size.x)),
                std::max(-half_size.y, std::min(local_point.y, half_size.y))
            ), theta) + center;

            _spatial_hash_dynamic[v2i(global_cell)] = v2f(closest);
        }
    }
}

void CalcoRope::update_spatial_hash_dynamic_circle(Vector2 center, float radius) {
    float offset = _collision_radius;
    Vector2i top_left_cell = Vector2(center.x - radius - offset, center.x - radius - offset) / (_collision_radius / 2.0);
    Vector2i bottom_right_cell = Vector2(center.y + radius + offset, center.y + radius + offset) / (_collision_radius / 2.0);
    for (int y = top_left_cell.y - 1; y < bottom_right_cell.y + 1; ++y) {
        for (int x = top_left_cell.x - 1; x < bottom_right_cell.x + 1; ++x) {
            Vector2i global_cell = Vector2i(x, y);
            Vector2 global_pos = global_cell * (_collision_radius / 2.0);
            Vector2 diff = global_pos - center;
            Vector2 closest = global_pos + diff.normalized() * (_collision_radius + radius - diff.length());
            _spatial_hash_dynamic[v2i(global_cell)] = v2f(closest);
        }
    }
}

void CalcoRope::print_spatial_hash(Vector2 top_left, Vector2 bottom_right) {
    // godot::print_line("Printing spatial hash!");
    Vector2i top_left_cell = top_left / (_collision_radius / 2.0);
    Vector2i bottom_right_cell = bottom_right / (_collision_radius / 2.0);
    for (int y = top_left_cell.y; y < bottom_right_cell.y; ++y) {
        for (int x = top_left_cell.x; x < bottom_right_cell.x; ++x) {
            Vector2i global_cell = top_left_cell + Vector2i(x, y);
            // Vector2 global_position_pos = global_cell * _collision_radius;
            v2f v = _spatial_hash[v2i(global_cell)];
            Vector2 vv = Vector2(v.x, v.y);
            if (vv != Vector2(0, 0)) {
                // godot::print_line(global_cell, ": ", vv);
            }
        }
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

        if (_lasso_enabled) {
            point_diff = _points[_point_count - 1].pos - _points[_lasso_index].pos;
            diff = point_diff.length() - get_segment_length();
            change = point_diff.normalized() * diff * 0.5f;
            _points[_point_count - 1].pos -= change;
            _points[_lasso_index].pos += change;

            if (_lasso_circular_force_factor > 0.0) {
                Vector2 center = Vector2(0, 0);
                int loop_point_count = _point_count - _lasso_index;
                for (int i = _lasso_index; i < _point_count; ++i) {
                    center += _points[i].pos;
                }
                center /= static_cast<float>(loop_point_count);

                // Target radius based on lasso diameter
                float target_radius = _lasso_diameter / 2.0f;

                // Apply outward/inward correction to each loop point
                for (int i = _lasso_index; i < _point_count; ++i) {
                    Vector2 to_point = _points[i].pos - center;
                    float current_distance = to_point.length();
                    if (current_distance > 0.0f) { // Avoid division by zero
                        Vector2 radial_dir = to_point / current_distance;
                        float distance_diff = target_radius - current_distance;
                        // Apply small correction along radial direction
                        Vector2 correction = radial_dir * (distance_diff * _lasso_circular_force_factor);
                        _points[i].pos += correction;
                    }
                }
            }
        }

        if (ic % _collision_run_interval == 0) {
            for (RopePoint& point : _points) {
                Vector2 vel = point.pos - point.prev_pos;

                Vector2i grid_cell = point.pos / (_collision_radius / 2.0);
                Vector2 closest_point;
                float min_dist = 999.9;
                for (int yoff = -1; yoff < 2; ++yoff) {
                    for (int xoff = -1; xoff < 2; ++xoff) {
                        v2i hash_point = grid_cell + Vector2i(xoff, yoff);

                        auto normal_it = _spatial_hash.find(hash_point);
                        auto dynamic_it = _spatial_hash_dynamic.find(hash_point);


                        v2f _closest_point;
                        if (normal_it != _spatial_hash.end() && dynamic_it != _spatial_hash_dynamic.end()) {
                            v2f normal_hash_point = _spatial_hash[hash_point];
                            float normal_dist = point.pos.distance_to(Vector2(normal_hash_point.x, normal_hash_point.y));
                            v2f dynamic_hash_point = _spatial_hash_dynamic[hash_point];
                            float dynamic_dist = point.pos.distance_to(Vector2(dynamic_hash_point.x, dynamic_hash_point.y));
                            _closest_point = (normal_dist < dynamic_dist) ? normal_hash_point : dynamic_hash_point;
                        }
                        else if (normal_it != _spatial_hash.end()) {
                            _closest_point = normal_it->second;
                        }
                        else if (dynamic_it != _spatial_hash_dynamic.end()) {
                            _closest_point = dynamic_it->second;
                        } else {
                            continue;
                        }

                        Vector2 cp = Vector2(_closest_point.x, _closest_point.y);
                        float distance = point.pos.distance_to(cp);
                        if (distance < min_dist) {
                            min_dist = distance;
                            closest_point = cp;
                        }
                    }
                }

                if (min_dist < _collision_radius) {
                    Vector2 normal = (point.pos - closest_point).normalized();
                    float depth = _collision_radius - min_dist;
                    point.pos += normal * depth;

                    if (normal != Vector2(0, 0)) {
                        Vector2 b = vel.bounce(normal) * _bounce_factor;
                        vel = b;
                    } else {
                        vel = normal;
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

bool CalcoRope::get_lasso_enabled() const {
    return _lasso_enabled;
}

void CalcoRope::set_lasso_enabled(const bool lasso_enabled) {
    _lasso_enabled = lasso_enabled;
}

float CalcoRope::get_lasso_diameter() const {
    return _lasso_diameter;
}

void CalcoRope::set_lasso_diameter(const float lasso_diameter) {
    _lasso_diameter = lasso_diameter;

    float segment_length = get_segment_length();
    int loop_segments = (int)(std::floor(3.14159 * lasso_diameter / segment_length));
    _lasso_index = _point_count - loop_segments;
}

float CalcoRope::get_lasso_circular_force_factor() const {
    return _lasso_circular_force_factor;
}

void CalcoRope::set_lasso_circular_force_factor(const float factor) {
    _lasso_circular_force_factor = factor;
}

Vector2 CalcoRope::get_origin() const {
    return _origin;
}

void CalcoRope::set_origin(const Vector2 origin) {
    _origin = origin;
}

int CalcoRope::get_lasso_index() const {
    return _lasso_index;
}