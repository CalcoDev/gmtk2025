#ifndef CALCO_ROPE_H
#define CALCO_ROPE_H

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/line2d.hpp>
#include <godot_cpp/classes/shape_cast2d.hpp>

namespace calco_rope_sim {
    struct RopePoint {
        godot::Vector2 pos;
        godot::Vector2 prev_pos;

		RopePoint() : pos(godot::Vector2(0, 0)), prev_pos(godot::Vector2(0, 0)) {}
        RopePoint(const godot::Vector2& position) : pos(position), prev_pos(position) {}
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
	float _total_rope_distance;

	Vector2 _origin;

protected:
	static void _bind_methods();

public:
	CalcoRope();
	~CalcoRope();

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