#ifndef CALCO_ROPE_H
#define CALCO_ROPE_H

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/line2d.hpp>
#include <godot_cpp/classes/shape_cast2d.hpp>

#include <functional>

namespace calco_rope_sim {
    struct RopePoint {
        godot::Vector2 pos;
        godot::Vector2 prev_pos;

		RopePoint() : pos(godot::Vector2(0, 0)), prev_pos(godot::Vector2(0, 0)) {}
        RopePoint(const godot::Vector2& position) : pos(position), prev_pos(position) {}
    };

	struct v2i {
		int x;
		int y;

		v2i() : x(0.0), y(0.0) {}
		v2i(const int p_x, const int p_y) : x(p_x), y(p_y) {}
		v2i(const godot::Vector2i position) : x(position.x), y(position.y) {}

		bool operator==(const v2i& other) const {
            return x == other.x && y == other.y;
        }
	};
	
	struct v2f {
		double x;
		double y;

		v2f() : x(0.0), y(0.0) {}
		v2f(const double p_x, const double p_y) : x(p_x), y(p_y) {}
		v2f(const godot::Vector2 position) : x(position.x), y(position.y) {}
	};
}

namespace std {
    template <>
    struct hash<calco_rope_sim::v2i> {
        std::size_t operator()(const calco_rope_sim::v2i& v) const noexcept {
            // Combine the hash of x and y
            std::size_t h1 = std::hash<int>{}(v.x);
            std::size_t h2 = std::hash<int>{}(v.y);
            return h1 ^ (h2 << 1); // Simple hash combination
        }
    };
}

namespace godot {

class CalcoRope : public Node2D {
	GDCLASS(CalcoRope, Node2D)

private:
	// refs
    NodePath _line_path;
    NodePath _shape_cast_path;

	Line2D* _line;
	ShapeCast2D* _shape_cast;

	// rope settings
	int _point_count;
	float _length;
	
	// simulation settings
	Vector2 _gravity;
	float _damp_factor;
	int _constraint_run_count;
	int _collision_run_interval;
	float _collision_radius;
	float _bounce_factor;

	// private stuff
	std::vector<calco_rope_sim::RopePoint> _points;
	std::unordered_map<calco_rope_sim::v2i, calco_rope_sim::v2f> _spatial_hash;
	std::unordered_map<calco_rope_sim::v2i, calco_rope_sim::v2f> _spatial_hash_dynamic;

	float _total_rope_distance;

	Vector2 _origin;

protected:
	static void _bind_methods();

public:
	CalcoRope();
	~CalcoRope();

	void print_spatial_hash(Vector2 top_left, Vector2 bottom_right);
	void update_spatial_hash(Vector2 top_left, Vector2 bottom_right);

	void clear_spatial_hash_dyanmic();
	// void update_spatial_hash_dynamic(Vector2 top_left, Vector2 bottom_right, int shape_type);
	void update_spatial_hash_dynamic_obb(Vector2 center, Vector2 half_size, double theta);
	void update_spatial_hash_dynamic_circle(Vector2 center, float radius);
	// void update_spatial_hash_dynamic_capsule();

	void update_simulation(double delta);
	void render_simulation(double delta);

	void _ready() override;
	void _process(double delta) override;
	void _physics_process(double delta) override;

    NodePath get_line_path() const;
    void set_line_path(const NodePath& path);
	
    NodePath get_shape_cast_path() const;
    void set_shape_cast_path(const NodePath& path);

    int get_point_count() const;
    void set_point_count(const int point_count);

    float get_length() const;
    void set_length(const float length);

	// getters and setters
	float get_total_rope_distance() const;
	float get_segment_length() const;

	void set_point(const int index, const Vector2 position);
	Vector2 get_point(const int index) const;

    // Getters and setters for simulation properties
    Vector2 get_gravity() const;
    void set_gravity(const Vector2 gravity);
    float get_damp_factor() const;
    void set_damp_factor(const float damp_factor);
    int get_constraint_run_count() const;
    void set_constraint_run_count(const int constraint_run_count);
    int get_collision_run_interval() const;
    void set_collision_run_interval(const int collision_run_interval);
    float get_collision_radius() const;
    void set_collision_radius(const float collision_radius);
    float get_bounce_factor() const;
    void set_bounce_factor(const float bounce_factor);

    Vector2 get_origin() const;
    void set_origin(const Vector2 origin);
};

}

#endif