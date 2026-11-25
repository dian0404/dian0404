---
name: github-project-covers
description: Automatically prepare a new project's cover image for Dian's GitHub profile README. Use when adding, replacing, or normalizing a project cover in the dian0404/dian0404 profile repository; preserves the source, makes a consistent 1600x900 crop with the established antique-gold rounded frame, and updates only the matching README image reference when asked to integrate it.
---

# GitHub project cover workflow

Use this skill whenever a new project is added to the Selected Projects section or its cover needs replacement. The goal is a uniform set of covers with matching dimensions, color treatment, edge finish, and readable subject framing.

## Style standard

- Canvas: exactly 1600 × 900 pixels (16:9).
- Format: PNG, sRGB, 8-bit RGB/RGBA. Keep output files reasonably sized; avoid accidental 2x Retina canvases.
- Treatment: retain the source image's subject and existing rose/vintage character. Do not invent project UI, text, awards, or results.
- Crop: use a centered 16:9 crop when it keeps the subject intact. If the center crop cuts off the main subject, adjust crop position based on visual inspection. Never stretch an image.
- Finish: consistent antique-gold frame (#D4AF37), 3 px at final resolution, with 25 px rounded corners. Preserve transparency outside the rounded corners.
- Detail: process all covers through the same color-management and resize path. Do not apply per-image sharpening, saturation, or contrast adjustments. If a source is already sharp, keep it; if it is visibly soft, explain that a uniform canvas cannot recover lost detail.
- Do not upscale tiny sources as if that creates detail. If the source's short edge is below 600 px or visibly soft, ask for a higher-resolution source or offer image generation for a stylistically consistent redraw. Generated redraws should not contain fake readable interface text, measurements, scores, financial figures, awards, or results.

## Workflow

1. Identify the source asset, intended project title/README row, and destination filename. If those cannot be inferred from the current request/repository, ask one concise question before editing.
2. Inspect source dimensions and image content. Preserve the original file.
3. If the source short edge is below 600 px or visibly soft, do not upscale it as a final. Ask the user for a higher-resolution source or permission to generate a stylistically consistent replacement; if generation is approved, make the scene representative without inventing project-specific facts. Keep all four covers in the same image-generation pass/style where possible.
4. Run `swift scripts/make_cover.swift SOURCE OUTPUT.png` to create the normalized cover. Review its crop visually when the source is not already 16:9.
5. Verify the output by reopening it and checking actual dimensions, mode, format, and file size. It must be exactly 1600 × 900, PNG, RGB/RGBA. Do not trust the requested resize dimensions without reopening the result.
6. When the user requested integrating the cover, update only the corresponding image `src` in README.md. Keep project text, links, and other cards untouched. GitHub profile READMEs sanitize inline CSS, so rely on the baked image frame; do not use CSS `object-fit` as the only crop mechanism.
7. Check all four project assets together at the same displayed size for framing, relative sharpness, color, border, and rounded corners. If one visibly differs, refine the crop or request a better source.
8. Report the output filename, verified dimensions, source limitations, README change, and whether the GitHub page was actually checked. Do not commit or push unless explicitly asked.

## Naming

Use a stable filename such as `assets/project-<slug>-cover.png`. Preserve old/source files. Replace the README reference only after the new file passes verification.

## Quality limits

An identical canvas cannot make low-resolution or blurry source material equally detailed. Do not conceal this by strong sharpening or synthetic texture. Explain the source limitation and let the user choose a higher-quality source or a generated restyle.
