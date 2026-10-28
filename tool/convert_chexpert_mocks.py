"""Convert the CheXpert Plus studies behind the image-review mocks into PNGs.

CheXpert Plus is used under a research use agreement, so its images stay on
this machine: the output folder is git-ignored and nothing it holds is
committed. The app's mocks (lib/data/mocks/image_review_mocks.dart) point at
these files; on a machine without them, AppImage shows its broken-image
placeholder instead.

Usage (or `make mock-images`):

    uv run --no-project --with 'pydicom>=3' --with numpy --with pillow \
        python -I tool/convert_chexpert_mocks.py <CHEXPERT_DIR> <OUT_DIR>

CHEXPERT_DIR is the folder holding the `patientNNNNN/` directories of the
uncompressed DICOM `train` split.
"""

import sys
from pathlib import Path

import numpy as np
import pydicom
from PIL import Image
from pydicom.pixels import apply_voi_lut

# Output name -> DICOM path under CHEXPERT_DIR. case-7 is a frontal film whose
# header says left lateral, beside its study's PA and true lateral; case-8's
# first image is blank.
STUDIES = {
    "case-7-view1.png": "patient29942/study3/view1_frontal.dcm",
    "case-7-view2.png": "patient29942/study3/view2_frontal.dcm",
    "case-7-view3.png": "patient29942/study3/view3_lateral.dcm",
    "case-8-view1.png": "patient25979/study8/view1_frontal.dcm",
    "case-8-view2.png": "patient25979/study8/view2_frontal.dcm",
    "case-8-view3.png": "patient25979/study8/view3_lateral.dcm",
}

# The long side, matching the 1024-pixel NIH images the other mocks use.
LONG_SIDE = 1024


def window(ds: pydicom.Dataset) -> np.ndarray:
    """The pixels mapped to 0..1 through the file's window, or one we pick."""
    if "WindowCenter" in ds or "VOILUTSequence" in ds:
        # apply_voi_lut maps into the stored bit depth's full range.
        pixels = apply_voi_lut(ds.pixel_array, ds).astype(np.float64)
        low, high = 0.0, float(2 ** int(ds.BitsStored) - 1)
    else:
        # No window in the header, so pick one as a viewer would: the
        # 0.5-99.5 percentile range. When that range is empty (a blank film,
        # nearly every pixel one value) fall back to the full stored range,
        # so the film stays blank instead of having its noise stretched.
        pixels = ds.pixel_array.astype(np.float64)
        low, high = np.percentile(pixels, [0.5, 99.5])
        if high <= low:
            low, high = 0.0, float(2 ** int(ds.BitsStored) - 1)
    return np.clip((pixels - low) / (high - low), 0.0, 1.0)


def to_png(source: Path, target: Path) -> None:
    ds = pydicom.dcmread(source)
    pixels = window(ds)
    if ds.PhotometricInterpretation == "MONOCHROME1":
        pixels = 1.0 - pixels
    image = Image.fromarray(np.round(pixels * 255).astype(np.uint8), mode="L")
    image.thumbnail((LONG_SIDE, LONG_SIDE), Image.Resampling.LANCZOS)
    # A fresh image carries no DICOM metadata; save it without any text chunks.
    image.save(target, format="PNG", optimize=True)


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    chexpert_dir, out_dir = Path(argv[1]), Path(argv[2])
    if not chexpert_dir.is_dir():
        print(f"CheXpert folder not found: {chexpert_dir}", file=sys.stderr)
        return 1
    out_dir.mkdir(parents=True, exist_ok=True)
    for name, relative in STUDIES.items():
        to_png(chexpert_dir / relative, out_dir / name)
        print(f"{relative} -> {out_dir / name}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
