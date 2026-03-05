FROM condaforge/miniforge3:26.1.0-0

# Install system utilities AND build tools (g++) needed for compiling MOODS-python
RUN apt-get update && apt-get install -y procps build-essential && apt-get clean

# Copy the environment file AND the graphlan directory
COPY environment.yml /tmp/environment.yml
COPY graphlan /tmp/graphlan

# Install dependencies
# This step compiles MOODS-python, so g++ must be available before this runs
RUN mamba env update -n base -f /tmp/environment.yml && \
    mamba clean -a -y

# Explicitly reinstall plantiSMASH to ensure correct versioning
RUN pip install plantismash==2.0.4

# Fix for potential "hmmpfam2 not found" errors
RUN if [ ! -f /opt/conda/bin/hmmpfam2 ]; then ln -s /opt/conda/bin/hmmpfam /opt/conda/bin/hmmpfam2; fi

# Fix permissions for runtime writing
# antismash writes to its installation directory at runtime, so we need to make it writable
RUN chmod -R 777 /opt/conda/lib/python3.8/site-packages/antismash

# Set working directory
WORKDIR /data

# Default command
CMD ["run_antismash.py", "--help"]