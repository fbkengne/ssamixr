**Social Contact Matrices for Sub‑Saharan Africa**

`ssamixr` provides harmonized, ready‑to‑use social contact matrices from empirical studies conducted across Sub‑Saharan Africa.  
The package includes **171 matrices** covering multiple countries, settings, and study designs — all standardized for infectious 
disease modeling and comparative epidemiology.

# 🚀 Installation

```r
# install.packages("devtools")
devtools::install_github("fbkengne/ssamixr")
```

🧭 Getting Started: A Simple Workflow
Most users will want to:

- List all available matrices
- Filter matrices by country, study, or location
- Select a matrix ID
- Retrieve the matrix
- Visualize it

Here is the recommended workflow.

1️⃣ List all matrices

```r
library(ssamixr)

all_mats <- list_matrices()
head(all_mats)
```

This returns a tibble with metadata for all 171 matrices.

2️⃣ Filter matrices

You can filter by:

- country
- study_id
- author_year
- location_type (All, HH, School, Work, Other)

Example: matrices from Kenya:

```r
kenya <- filter_matrices(country = "Kenya")
```

Example: household (HH) matrices:

```r
hh <- filter_matrices(location_type = "HH")
```

Example: combine filters:

```r
kenya_hh <- filter_matrices(country = "Kenya", location_type = "HH")
```

3️⃣ Select a matrix ID

```r
id <- kenya$matrix_id[1]
id
```

4️⃣ Retrieve the matrix

```r
m <- get_matrix(id)
m$matrix      # numeric matrix
m$row_labels  # participant age groups
m$col_labels  # contact age groups
```

5️⃣ Visualize the matrix

```r
plot_matrix(m)
```

Or with a gradient:

```r
plot_matrix_gradient(m)
```

📊 Dataset Summary

The package contains:

- 171 social contact matrices
- covering 18 Sub‑Saharan African countries
- In Multiple settings:
  . All locations (All)
  . Household (HH)
  . School
  . Work
  . Other settings (Other)

- Each matrix includes:

  . A numeric contact matrix
  . Age‑group labels
  . Study metadata
  . Location type
  . Country and author‑year identifiers

🌍 Countries Included:
The package includes matrices from the following 18 countries:

- Angola
- Burkina Faso
- Cameroon
- Democratic Republic of Congo
- Ethiopia
- Gambia
- Ghana
- Guinea
- Ivory Coast
- Kenya
- Malawi
- Mozambique
- Nigeria
- Senegal
- South Africa
- Uganda
- Zambia
- Zimbabwe

(If you want, you can auto‑generate this list directly from the metadata.)

🏷️ Filtering Options
Users can filter matrices using the following metadata fields:

Field	Description
country:	Country name (18 total)
study_id:	Unique study identifier
author_year:	Author + publication year label
location_type:	Contact setting: All, HH, School, Work, Other

Example:

```r
filter_matrices(
  country = c("Kenya", "Uganda"),
  location_type = "School"
)
```

📦 Overview
ssamixr provides:

Age‑structured social contact matrices for Sub‑Saharan African countries
Harmonized metadata for filtering and selection
Tools for loading, inspecting, and visualizing matrices

A reproducible workflow for integrating matrices into transmission models
Designed for:
- Infectious disease modelers
- Public health researchers
- Policy analysts
- Students learning age‑structured modeling

🌍 Data Sources
The matrices included in ssamixr are derived from:
- Empirical contact surveys conducted across Sub‑Saharan Africa
- Harmonized demographic data
- Standardized processing pipelines ensuring comparability

Full details are available in the package vignette:

```r
vignette("ssamixr")
```

📁 Package Structure

ssamixr/
├── R/                 # Functions
├── data/              # Internal datasets
├── inst/              # Metadata and documentation
├── vignettes/         # Long-form documentation
└── dev/               # Development scripts

🤝 Contributing
Contributions are welcome.
If you would like to:
- Add new matrices
- Improve documentation
- Report issues
- Suggest enhancements

please open an issue or submit a pull request on GitHub.

📄 License
This package is released under the MIT License.
See LICENSE for details.

📬 Citation
If you use ssamixr in your research, please cite:

Kengne FB, et al. (2026). ssamixr: Social Contact Matrices for Sub‑Saharan Africa.
A full citation entry is available via:

```r
citation("ssamixr")
```

🧪 Reproducibility
This package follows best practices for reproducible research:

- Version‑controlled development
- Documented data processing pipelines
- Vignettes demonstrating usage
- Stable GitHub releases with DOIs (via Zenodo)

🙏 Acknowledgments
We thank the researchers, survey teams, and collaborators who contributed to the collection and harmonization of social contact data across Sub‑Saharan Africa.
