%module b2

%{
#include <Box2D/Common/b2Math.h>
%}

/// A 2D column vector.
struct b2Vec2
{
    b2Vec2();
    b2Vec2(float32 x, float32 y);
    void SetZero();
    void Set(float32 x_, float32 y_);
    b2Vec2 operator -() const;
    float32 operator () (int32 i) const;
    void operator += (const b2Vec2& v);
    void operator -= (const b2Vec2& v);
    void operator *= (float32 a);
    float32 Length() const;
    float32 LengthSquared() const;
    float32 Normalize();
    bool IsValid() const;
    b2Vec2 Skew() const;

    float32 x, y;
};
