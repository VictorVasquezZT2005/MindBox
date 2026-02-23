package com.mindbox.app;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class MindGraphView extends View {
    private List<Node> nodes = new ArrayList<>();
    private Paint nodePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private Paint linePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private int nodeCount = 20;
    private Random random = new Random();

    public MindGraphView(Context context, AttributeSet attrs) {
        super(context, attrs);
        nodePaint.setColor(Color.parseColor("#007AFF"));
        linePaint.setColor(Color.parseColor("#D1D1D6"));
        linePaint.setStrokeWidth(2f);
    }

    private void initNodes() {
        nodes.clear();
        for (int i = 0; i < nodeCount; i++) {
            nodes.add(new Node(
                random.nextFloat() * getWidth(),
                random.nextFloat() * getHeight(),
                (random.nextFloat() - 0.5f) * 4,
                (random.nextFloat() - 0.5f) * 4
            ));
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (nodes.isEmpty()) initNodes();

        // Mover nodos
        for (Node n : nodes) {
            n.x += n.vx;
            n.y += n.vy;
            if (n.x < 0 || n.x > getWidth()) n.vx *= -1;
            if (n.y < 0 || n.y > getHeight()) n.vy *= -1;
        }

        // Dibujar líneas con opacidad dinámica
        for (int i = 0; i < nodes.size(); i++) {
            for (int j = i + 1; j < nodes.size(); j++) {
                Node a = nodes.get(i);
                Node b = nodes.get(j);
                double dist = Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
                if (dist < 300) {
                    linePaint.setAlpha((int) (255 * (1 - dist / 300) * 0.2));
                    canvas.drawLine(a.x, a.y, b.x, b.y, linePaint);
                }
            }
        }

        // Dibujar puntos
        for (Node n : nodes) {
            canvas.drawCircle(n.x, n.y, 8, nodePaint);
        }

        invalidate(); // Forzar animación constante
    }

    private static class Node {
        float x, y, vx, vy;
        Node(float x, float y, float vx, float vy) {
            this.x = x; this.y = y; this.vx = vx; this.vy = vy;
        }
    }
}